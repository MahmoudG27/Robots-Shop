'use strict';

const express = require('express');
const { MongoClient } = require('mongodb');
const pino = require('pino');
const expressPino = require('express-pino-logger');
const promClient = require('prom-client');

// ---------- Prometheus ----------
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['service', 'method', 'route', 'status'],
  registers: [register]
});

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['service', 'method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register]
});

// ---------- Logger ----------
const logger = pino({ level: 'info' });
const expLogger = expressPino({ logger });

// ---------- App ----------
const app = express();
app.use(expLogger);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ---------- Security headers ----------
app.use((req, res, next) => {
  res.set('Timing-Allow-Origin', '*');
  res.set('Access-Control-Allow-Origin', '*');
  next();
});

// ---------- metrics ----------
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer({
    service: 'catalogue',
    method: req.method,
    route: req.path
  });

  res.on('finish', () => {
    httpRequestsTotal.inc({
      service: 'catalogue',
      method: req.method,
      route: req.path,
      status: res.statusCode
    });

    end({
      status: res.statusCode
    });
  });

  next();
});

// ---------- MongoDB state ----------
let client;
let collection;

let mongoConnected = false;
let mongoReady = false;

const mongoURL =
  process.env.MONGO_URL || 'mongodb://mongodb:27017/catalogue';

// ---------- Mongo connection loop ----------
async function mongoLoop() {
  try {
    client = new MongoClient(mongoURL);
    await client.connect();

    const db = client.db('catalogue');
    collection = db.collection('products');

    mongoConnected = true;
    mongoReady = true;

    logger.info('MongoDB connected');
  } catch (err) {
    mongoConnected = false;
    mongoReady = false;

    logger.error(err, 'MongoDB connection failed, retrying...');
    setTimeout(mongoLoop, 2000);
  }
}

mongoLoop();

// ---------- Health endpoints ----------

// Liveness (process is alive)
app.get('/health/live', (req, res) => {
  res.send('OK');
});

// Readiness (ready to serve traffic)
app.get('/health/ready', (req, res) => {
  if (mongoReady) {
    return res.send('Ready');
  }

  return res.status(500).json({
    mongo: 'down'
  });
});

// Optional debug health
app.get('/health', (req, res) => {
  res.json({
    live: true,
    ready: mongoReady,
    mongoConnected
  });
});

// ---------- Metrics ----------
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// ---------- Routes ----------

// all products
app.get('/products', async (req, res) => {
  if (!mongoReady) {
    return res.status(500).send('database not available');
  }

  try {
    const products = await collection.find({}).toArray();
    res.json(products);
  } catch (err) {
    logger.error(err);
    res.status(500).send(err);
  }
});

// product by SKU
app.get('/product/:sku', async (req, res) => {
  if (!mongoReady) {
    return res.status(500).send('database not available');
  }

  const delay = Number(process.env.GO_SLOW || 0);

  setTimeout(async () => {
    try {
      const product = await collection.findOne({ sku: req.params.sku });

      if (!product) {
        return res.status(404).send('SKU not found');
      }

      res.json(product);
    } catch (err) {
      logger.error(err);
      res.status(500).send(err);
    }
  }, delay);
});

// products by category
app.get('/products/:cat', async (req, res) => {
  if (!mongoReady) {
    return res.status(500).send('database not available');
  }

  try {
    const products = await collection
      .find({ categories: req.params.cat })
      .sort({ name: 1 })
      .toArray();

    res.json(products);
  } catch (err) {
    logger.error(err);
    res.status(500).send(err);
  }
});

// categories
app.get('/categories', async (req, res) => {
  if (!mongoReady) {
    return res.status(500).send('database not available');
  }

  try {
    const categories = await collection.distinct('categories');
    res.json(categories);
  } catch (err) {
    logger.error(err);
    res.status(500).send(err);
  }
});

// search
app.get('/search/:text', async (req, res) => {
  if (!mongoReady) {
    return res.status(500).send('database not available');
  }

  try {
    const hits = await collection
      .find({ $text: { $search: req.params.text } })
      .toArray();

    res.json(hits);
  } catch (err) {
    logger.error(err);
    res.status(500).send(err);
  }
});

// ---------- Start server ----------
const port = process.env.CATALOGUE_SERVER_PORT || 8080;

app.listen(port, () => {
  logger.info(`Catalogue service started on port ${port}`);
});

// ---------- Graceful shutdown ----------
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down...');

  try {
    if (client) await client.close();
    process.exit(0);
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down...');

  try {
    if (client) await client.close();
    process.exit(0);
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
});