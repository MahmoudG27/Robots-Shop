'use strict';

const express = require('express');
const redis = require('redis');
const axios = require('axios');
const pino = require('pino');
const expressPino = require('express-pino-logger');
const promClient = require('prom-client');

// ---------- Logger ----------
const logger = pino({ level: 'info' });
const expLogger = expressPino({ logger });

// ---------- Prometheus ----------
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const itemsAddedCounter = new promClient.Counter({
  name: 'cart_items_added_total',
  help: 'Total number of items added to cart',
  labelNames: ['service'],
  registers: [register]
});

// ---------- Config ----------
const redisHost = process.env.REDIS_HOST || 'redis';
const catalogueHost = process.env.CATALOGUE_HOST || 'catalogue';

let redisConnected = false;

// ---------- App ----------
const app = express();
app.use(expLogger);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  res.set('Timing-Allow-Origin', '*');
  res.set('Access-Control-Allow-Origin', '*');
  next();
});

// ---------- Health ----------
app.get('/health', (req, res) => {
  res.json({
    app: 'OK',
    redis: redisConnected
  });
});

// ---------- Metrics ----------
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// ---------- Redis ----------
const redisClient = redis.createClient({
  url: `redis://${redisHost}:6379`
});

redisClient.on('error', (err) => {
  logger.error(err, 'Redis error');
});

redisClient.on('ready', () => {
  logger.info('Redis connected');
  redisConnected = true;
});

redisClient.connect();

// ---------- Routes ----------
app.get('/cart/:id', async (req, res) => {
  try {
    const data = await redisClient.get(req.params.id);
    if (!data) return res.status(404).send('cart not found');
    res.json(JSON.parse(data));
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

app.delete('/cart/:id', async (req, res) => {
  try {
    const result = await redisClient.del(req.params.id);
    if (result === 0) return res.status(404).send('cart not found');
    res.send('OK');
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

app.get('/add/:id/:sku/:qty', async (req, res) => {
  const qty = Number(req.params.qty);
  if (!Number.isInteger(qty) || qty < 1) {
    return res.status(400).send('quantity must be a positive number');
  }

  try {
    const product = await getProduct(req.params.sku);
    if (!product) return res.status(404).send('product not found');
    if (product.instock === 0) return res.status(404).send('out of stock');

    const data = await redisClient.get(req.params.id);
    const cart = data
      ? JSON.parse(data)
      : { total: 0, tax: 0, items: [] };

    const item = {
      qty,
      sku: req.params.sku,
      name: product.name,
      price: product.price,
      subtotal: qty * product.price
    };

    cart.items = mergeList(cart.items, item, qty);
    cart.total = calcTotal(cart.items);
    cart.tax = calcTax(cart.total);

    await saveCart(req.params.id, cart);
    itemsAddedCounter.labels('cart').inc(qty);

    res.json(cart);
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

// ---------- Helpers ----------
function mergeList(list, product, qty) {
  const existing = list.find(i => i.sku === product.sku);
  if (existing) {
    existing.qty += qty;
    existing.subtotal = existing.qty * existing.price;
  } else {
    list.push(product);
  }
  return list;
}

function calcTotal(list) {
  return list.reduce((sum, i) => sum + i.subtotal, 0);
}

function calcTax(total) {
  return total - total / 1.2;
}

async function getProduct(sku) {
  try {
    const res = await axios.get(
      `http://${catalogueHost}:8080/product/${sku}`
    );
    return res.data;
  } catch {
    return null;
  }
}

async function saveCart(id, cart) {
  await redisClient.setEx(id, 3600, JSON.stringify(cart));
}

// ---------- Start ----------
const port = process.env.CART_SERVER_PORT || 8080;
app.listen(port, () => {
  logger.info(`Cart service started on port ${port}`);
});
