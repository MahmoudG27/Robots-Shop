import os
import sys
import time
import logging
import uuid
import json
import requests
import signal

from flask import Flask, Response, request, jsonify

from .rabbitmq import Publisher

import prometheus_client
from prometheus_client import Counter, Histogram

# =========================
# App setup
# =========================
app = Flask(__name__)
app.logger.setLevel(logging.INFO)

# =========================
# Config (env-based)
# =========================
CART = os.getenv('CART_HOST', 'cart')
USER = os.getenv('USER_HOST', 'user')
PAYMENT_GATEWAY = os.getenv('PAYMENT_GATEWAY', 'https://paypal.com/')

RABBITMQ_USER = os.getenv('RABBITMQ_USER', 'guest')
RABBITMQ_PASS = os.getenv('RABBITMQ_PASS', 'guest')

PAYMENT_DELAY_MS = int(os.getenv('PAYMENT_DELAY_MS', '0'))
PORT = int(os.getenv("SHOP_PAYMENT_PORT", "8080"))

# =========================
# Prometheus Metrics
# =========================
PromMetrics = {}

PromMetrics['SOLD_COUNTER'] = Counter(
    'sold_count', 'Running count of items sold'
)

PromMetrics['AUS'] = Histogram(
    'units_sold',
    'Average Unit Sale',
    buckets=(1, 2, 5, 10, 100)
)

PromMetrics['AVS'] = Histogram(
    'cart_value',
    'Average Value Sale',
    buckets=(100, 200, 500, 1000, 2000, 5000, 10000)
)

# =========================
# HTTP helper with retry
# =========================
def http_get(url, retries=3, timeout=2):
    last_err = None
    for _ in range(retries):
        try:
            return requests.get(url, timeout=timeout)
        except Exception as err:
            last_err = err
            time.sleep(0.3)
    raise last_err

def http_post(url, data, retries=3, timeout=2):
    last_err = None
    for _ in range(retries):
        try:
            return requests.post(url, data=data, timeout=timeout)
        except Exception as err:
            last_err = err
            time.sleep(0.3)
    raise last_err

def http_delete(url, retries=3, timeout=2):
    last_err = None
    for _ in range(retries):
        try:
            return requests.delete(url, timeout=timeout)
        except Exception as err:
            last_err = err
            time.sleep(0.3)
    raise last_err


# =========================
# RabbitMQ
# =========================
publisher = Publisher(app.logger, RABBITMQ_USER, RABBITMQ_PASS)


# =========================
# Error handler
# =========================
@app.errorhandler(Exception)
def exception_handler(err):
    app.logger.error(str(err))
    return str(err), 500


# =========================
# Health endpoints
# =========================
@app.route('/health/live', methods=['GET'])
def live():
    return 'OK', 200


@app.route('/health/ready', methods=['GET'])
def ready():
    try:
        http_get(f'http://{USER}:8080/health', timeout=2)
        http_get(f'http://{CART}:8080/health/live', timeout=2)
        return 'Ready', 200
    except Exception as err:
        app.logger.error(f"Readiness failed: {err}")
        return 'Not Ready', 500


# =========================
# Metrics
# =========================
@app.route('/metrics', methods=['GET'])
def metrics():
    res = []
    for m in PromMetrics.values():
        res.append(prometheus_client.generate_latest(m))

    return Response(res, mimetype='text/plain')


# =========================
# Payment endpoint
# =========================
@app.route('/pay/<id>', methods=['POST'])
def pay(id):
    app.logger.info(f'payment for {id}')

    cart = request.get_json()
    app.logger.info(cart)

    anonymous_user = True

    # check user exists
    try:
        req = http_get(f'http://{USER}:8080/check/{id}')
    except Exception as err:
        app.logger.error(err)
        return str(err), 500

    if req.status_code == 200:
        anonymous_user = False

    # validate cart
    has_shipping = any(
        item.get('sku') == 'SHIP'
        for item in cart.get('items', [])
    )

    if cart.get('total', 0) == 0 or not has_shipping:
        return 'cart not valid', 400

    # payment gateway call
    try:
        req = http_get(PAYMENT_GATEWAY)
    except Exception as err:
        app.logger.error(err)
        return str(err), 500

    if req.status_code != 200:
        return 'payment error', req.status_code

    # metrics
    item_count = countItems(cart.get('items', []))
    PromMetrics['SOLD_COUNTER'].inc(item_count)
    PromMetrics['AUS'].observe(item_count)
    PromMetrics['AVS'].observe(cart.get('total', 0))

    # order id
    orderid = str(uuid.uuid4())

    queueOrder({
        'orderid': orderid,
        'user': id,
        'cart': cart
    })

    # order history
    if not anonymous_user:
        try:
            req = http_post(
                f'http://{USER}:8080/order/{id}',
                data=json.dumps({'orderid': orderid, 'cart': cart}),
                headers={'Content-Type': 'application/json'}
            )
        except Exception as err:
            app.logger.error(err)
            return str(err), 500

    # delete cart
    try:
        req = http_delete(f'http://{CART}:8080/cart/{id}')
    except Exception as err:
        app.logger.error(err)
        return str(err), 500

    if req.status_code != 200:
        return 'cart delete error', req.status_code

    return jsonify({'orderid': orderid})


# =========================
# Queue order
# =========================
def queueOrder(order):
    app.logger.info('queue order')

    time.sleep(PAYMENT_DELAY_MS / 1000)

    publisher.publish(order, {})


# =========================
# Helpers
# =========================
def countItems(items):
    return sum(
        item.get('qty', 0)
        for item in items
        if item.get('sku') != 'SHIP'
    )


# =========================
# Graceful shutdown
# =========================
def shutdown_handler(signum, frame):
    app.logger.info("Shutting down payment service...")
    publisher.close()
    sys.exit(0)


signal.signal(signal.SIGTERM, shutdown_handler)
signal.signal(signal.SIGINT, shutdown_handler)


# =========================
# Start server
# =========================
if __name__ == "__main__":
    app.logger.info(f'Payment gateway {PAYMENT_GATEWAY}')
    app.logger.info(f'Starting on port {PORT}')

    app.run(host='0.0.0.0', port=PORT)