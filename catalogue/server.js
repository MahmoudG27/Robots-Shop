'use strict';

const express = require('express');
const { MongoClient } = require('mongodb');
const pino = require('pino');
const expressPino = require('express-pino-logger');
const promClient = require('prom-client');

// ---------- Logger ----------
const logger = pino({ level: 'info' });
const expLogger = expressPino({ logger });

// ---------- Prometheus ----------
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

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

// ---------- MongoDB ----------
let client;
let collection;
let mongoConnected = false;

const mongoURL =
  process.env.MONGO_URL || 'mongodb://mongodb:27017/catalogue';

async function mongoLoop() {
  try {
    client = new MongoClient(mongoURL);
    await client.connect();

    const db = client.db('catalogue');
    collection = db.collection('products');

    mongoConnected = true;
    logger.info('MongoDB connected');
  } catch (err) {
    mongoConnected = false;
    logger.error(err, 'MongoDB connection failed, retrying...');
    setTimeout(mongoLoop, 2000);
  }
}

mongoLoop();

// ---------- Health ----------
app.get('/health', (req, res) => {
  res.json({
    app: 'OK',
    mongo: mongoConnected
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
  if (!mongoConnected) {
    return res.status(500).send('database not available');
  }

  try {
    const products = await collection.find({}).toArray();
    res.json(products);
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

// product by SKU
app.get('/product/:sku', async (req, res) => {
  if (!mongoConnected) {
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
      req.log.error(err);
      res.status(500).send(err);
    }
  }, delay);
});

// products in a category
app.get('/products/:cat', async (req, res) => {
  if (!mongoConnected) {
    return res.status(500).send('database not available');
  }

  try {
    const products = await collection
      .find({ categories: req.params.cat })
      .sort({ name: 1 })
      .toArray();

    res.json(products);
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

// all categories
app.get('/categories', async (req, res) => {
  if (!mongoConnected) {
    return res.status(500).send('database not available');
  }

  try {
    const categories = await collection.distinct('categories');
    res.json(categories);
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

// search name and description
app.get('/search/:text', async (req, res) => {
  if (!mongoConnected) {
    return res.status(500).send('database not available');
  }

  try {
    const hits = await collection
      .find({ $text: { $search: req.params.text } })
      .toArray();

    res.json(hits);
  } catch (err) {
    req.log.error(err);
    res.status(500).send(err);
  }
});

// ---------- Start ----------
const port = process.env.CATALOGUE_SERVER_PORT || 8080;

app.listen(port, () => {
  logger.info(`Catalogue service started on port ${port}`);
});