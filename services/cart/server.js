'use strict';

const express = require('express');
const redis = require('redis');
const axios = require('axios');
const pino = require('pino');
const expressPino = require('express-pino-logger');
const promClient = require('prom-client');
const logger = pino({ level: 'info' });

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
function validateEnv() {
  if (!process.env.REDIS_HOST) {
    logger.warn('REDIS_HOST not set, using default');
  }
  if (!process.env.CATALOGUE_HOST) {
    logger.warn('CATALOGUE_HOST not set, using default');
  }
}

validateEnv();

const redisHost = process.env.REDIS_HOST || 'redis';
const catalogueHost = process.env.CATALOGUE_HOST || 'catalogue';

let redisConnected = false;

// ---------- App ----------
const app = express();

// ---------- Security ----------

app.use((req, res, next) => {
  res.set('X-Content-Type-Options', 'nosniff');
  res.set('X-Frame-Options', 'DENY');
  next();
});

// ---------- Request ID ----------

const { randomUUID } = require('crypto');

app.use((req, res, next) => {
  const requestId = randomUUID();
  req.id = requestId;
  res.set('X-Request-ID', requestId);
  next();
});

// ---------- Logger ----------

const expLogger = expressPino({
  logger,
  genReqId: (req) => req.id
});

app.use(expLogger);

// ---------- Body parsing ----------

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ---------- Timeout ----------

app.use((req, res, next) => {
  res.setTimeout(5000, () => {
    if (!res.headersSent) {
      logger.warn('Request timeout');
      res.status(408).send('Request Timeout');
    }
  });
  next();
});

// ---------- CORS ----------

const allowedOrigin = process.env.ALLOWED_ORIGIN || '*';
app.use((req, res, next) => {
  res.set('Access-Control-Allow-Origin', allowedOrigin);
  res.set('Access-Control-Allow-Methods', 'GET,POST,DELETE');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  next();
});

// ---------- Rate limit ----------

const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100
});

app.use('/cart', limiter);
app.use('/add', limiter);
app.use('/shipping', limiter);

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

redisClient.on('end', () => {
  logger.warn('Redis disconnected');
  redisConnected = false;
});

redisClient.on('reconnecting', () => {
  logger.info('Redis reconnecting...');
});

(async () => {
  try {
    await redisClient.connect();
  } catch (err) {
    logger.error(err, 'Redis initial connection failed');
  }
})();

// ---------- Routes ----------
app.get('/rename/:from/:to', async (req, res) => {
  try {
    const data = await redisClient.get(req.params.from);
    if (data) {
      await redisClient.setEx(req.params.to, 3600, data);
      await redisClient.del(req.params.from);
    }
    res.send('OK');
  } catch (err) {
    res.status(500).send(err);
  }
});

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

app.post('/shipping/:id', async (req, res) => {
  try {
    const data = await redisClient.get(req.params.id);
    if (!data) return res.status(404).send('cart not found');

    const cart = JSON.parse(data);
    // Add shipping information to cart
    cart.shipping = req.body;

    const shippingItem = {
      qty: 1,
      sku: 'SHIP',
      name: 'Shipping',
      price: req.body.cost || 0,
      subtotal: req.body.cost || 0
    };

    const existing = cart.items.find(i => i.sku === 'SHIP');
    if (existing) {
      existing.price = shippingItem.price;
      existing.subtotal = shippingItem.subtotal;
    } else {
      cart.items = cart.items || [];
      cart.items.push(shippingItem);
    }

    cart.total = calcTotal(cart.items);
    cart.tax = calcTax(cart.total);

    await saveCart(req.params.id, cart);
    res.json(cart);
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

// ---------- check Catalogue ----------

const axiosInstance = axios.create({
  timeout: 5000
});

async function checkCatalogue() {
  try {
    await axiosInstance.get(`http://${catalogueHost}:8080/health`);
    return true;
  } catch {
    return false;
  }
}

// ---------- Health ----------

app.get('/health/live', (req, res) => {
  res.send('OK');
});

app.get('/health/ready', async (req, res) => {
  try {
    await redisClient.ping();

    const catalogueOk = await checkCatalogue();
    if (!catalogueOk) {
      throw new Error('Catalogue not reachable');
    }

    res.send('Ready');
  } catch (err) {
    logger.error(err, 'Readiness check failed');
    res.status(500).json({
      redis: redisConnected ? 'ok' : 'down',
      catalogue: 'down'
    });
  }
});

// ---------- Metrics ----------
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
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

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function getProduct(sku, retries = 3) {
  try {
    const res = await axiosInstance.get(
      `http://${catalogueHost}:8080/product/${sku}`
    );
    return res.data;
  } catch (err) {
    if (retries > 0) {
      await sleep(300);
      return getProduct(sku, retries - 1);
    }
    logger.error(err, 'Catalogue failed after retries');
    return null;
  }
}

async function saveCart(id, cart) {
  await redisClient.setEx(id, 3600, JSON.stringify(cart));
}

// ---------- Start ----------
const port = process.env.CART_SERVER_PORT || 8080;

const server = app.listen(port, () => {
  logger.info(`Cart service started on port ${port}`);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received. Shutting down...');
  try {
    await redisClient.quit();
    server.close(() => {
      process.exit(0);
    });
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
});

process.on('SIGTERM', async () => {
  logger.info('SIGTERM received. Shutting down...');
  try {
    await redisClient.quit();
    server.close(() => {
      process.exit(0);
    });
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
});