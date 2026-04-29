'use strict';

const express = require('express');
const bodyParser = require('body-parser');
const pino = require('pino');
const expressPino = require('express-pino-logger');
const redis = require('redis');
const { MongoClient } = require('mongodb');
const client = require('prom-client');

/* =========================
   Logger
========================= */
const logger = pino({ level: 'info' });
const expLogger = expressPino({ logger });

/* =========================
   Prometheus
========================= */
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestDuration = new client.Histogram({
  name: 'user_http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register]
});

/* =========================
   App
========================= */
const app = express();
app.use(expLogger);

/* Request + metrics timing */
app.use((req, res, next) => {
  res.set('Access-Control-Allow-Origin', '*');

  const end = httpRequestDuration.startTimer({
    method: req.method,
    route: req.path
  });

  res.on('finish', () => {
    end({ status: res.statusCode });
  });

  next();
});

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

/* =========================
   Redis
========================= */
const redisClient = redis.createClient({
  url: `redis://${process.env.REDIS_HOST || 'redis'}:6379`
});

let redisReady = false;

redisClient.on('error', (err) => logger.error(err, 'Redis error'));

(async () => {
  try {
    await redisClient.connect();
    redisReady = true;
    logger.info('Redis connected');
  } catch (err) {
    logger.error(err, 'Redis connection failed');
  }
})();

/* =========================
   MongoDB
========================= */
const mongoUrl = process.env.MONGO_URL || 'mongodb://mongodb:27017';

const mongoClient = new MongoClient(mongoUrl);

let db;
let usersCollection;
let ordersCollection;

let mongoConnected = false;
let mongoReady = false;

async function connectMongo() {
  try {
    await mongoClient.connect();
    db = mongoClient.db('users');
    usersCollection = db.collection('users');
    ordersCollection = db.collection('orders');

    mongoConnected = true;
    mongoReady = true;

    logger.info('MongoDB connected');
  } catch (err) {
    mongoConnected = false;
    mongoReady = false;

    logger.error(err, 'MongoDB connection failed, retrying...');
    setTimeout(connectMongo, 2000);
  }
}

connectMongo();

/* =========================
   Health endpoints
========================= */

// Liveness
app.get('/health/live', (req, res) => {
  res.send('OK');
});

// Readiness
app.get('/health/ready', (req, res) => {
  if (mongoReady && redisReady) {
    return res.send('Ready');
  }

  return res.status(500).json({
    mongo: mongoReady ? 'up' : 'down',
    redis: redisReady ? 'up' : 'down'
  });
});

// Debug health
app.get('/health', (req, res) => {
  res.json({
    live: true,
    mongo: mongoConnected,
    redis: redisReady
  });
});

/* =========================
   Metrics
========================= */
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

/* =========================
   Routes
========================= */

// unique id
app.get('/uniqueid', async (req, res) => {
  try {
    const value = await redisClient.incr('anonymous-counter');
    res.json({ uuid: `anonymous-${value}` });
  } catch (err) {
    logger.error(err);
    res.status(500).send('Redis error');
  }
});

// check user
app.get('/check/:id', async (req, res) => {
  if (!mongoReady) return res.status(500).send('database not available');

  try {
    const user = await usersCollection.findOne({ name: req.params.id });
    return user ? res.send('OK') : res.status(404).send('user not found');
  } catch (err) {
    logger.error(err);
    res.status(500).send(err);
  }
});

// login
app.post('/login', async (req, res) => {
  if (!mongoReady) return res.status(500).send('database not available');

  try {
    const user = await usersCollection.findOne({ name: req.body.name });

    if (!user) return res.status(404).send('name not found');

    return user.password === req.body.password
      ? res.json(user)
      : res.status(401).send('incorrect password');
  } catch (err) {
    logger.error(err);
    res.status(500).send(err);
  }
});

// register
app.post('/register', async (req, res) => {
  if (!mongoReady) return res.status(500).send('database not available');

  try {
    const exists = await usersCollection.findOne({ name: req.body.name });

    if (exists) return res.status(400).send('name already exists');

    await usersCollection.insertOne(req.body);
    res.send('OK');
  } catch (err) {
    logger.error(err);
    res.status(500).send(err);
  }
});

/* =========================
   Start server
========================= */
const port = process.env.USER_SERVER_PORT || 8080;

const server = app.listen(port, () => {
  logger.info(`User service started on port ${port}`);
});

/* =========================
   Graceful shutdown
========================= */
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received');

  try {
    if (mongoClient) await mongoClient.close();
    if (redisClient) await redisClient.quit();

    server.close(() => process.exit(0));
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received');

  try {
    if (mongoClient) await mongoClient.close();
    if (redisClient) await redisClient.quit();

    server.close(() => process.exit(0));
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
});