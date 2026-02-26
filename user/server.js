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
client.collectDefaultMetrics();

const httpRequestDuration = new client.Histogram({
  name: 'user_http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 1, 2, 5]
});

/* =========================
   App
========================= */
const app = express();
app.use(expLogger);

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

redisClient.on('error', err => logger.error(err, 'Redis error'));
redisClient.connect();

/* =========================
   MongoDB
========================= */
const mongoUrl = process.env.MONGO_URL || 'mongodb://mongodb:27017';
const mongoClient = new MongoClient(mongoUrl);

let db;
let usersCollection;
let ordersCollection;
let mongoConnected = false;

async function connectMongo() {
  try {
    await mongoClient.connect();
    db = mongoClient.db('users');
    usersCollection = db.collection('users');
    ordersCollection = db.collection('orders');
    mongoConnected = true;
    logger.info('MongoDB connected');
  } catch (err) {
    logger.error(err, 'MongoDB connection failed');
    setTimeout(connectMongo, 2000);
  }
}

connectMongo();

/* =========================
   Routes
========================= */
app.get('/health', (req, res) => {
  res.json({
    app: 'OK',
    mongo: mongoConnected
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.get('/uniqueid', async (req, res) => {
  try {
    const value = await redisClient.incr('anonymous-counter');
    res.json({ uuid: `anonymous-${value}` });
  } catch (err) {
    req.log.error(err);
    res.status(500).send('Redis error');
  }
});

app.get('/check/:id', async (req, res) => {
  if (!mongoConnected) return res.status(500).send('database not available');

  const user = await usersCollection.findOne({ name: req.params.id });
  user ? res.send('OK') : res.status(404).send('user not found');
});

app.post('/login', async (req, res) => {
  if (!mongoConnected) return res.status(500).send('database not available');

  const user = await usersCollection.findOne({ name: req.body.name });
  if (!user) return res.status(404).send('name not found');

  user.password === req.body.password
    ? res.json(user)
    : res.status(404).send('incorrect password');
});

app.post('/register', async (req, res) => {
  if (!mongoConnected) return res.status(500).send('database not available');

  const exists = await usersCollection.findOne({ name: req.body.name });
  if (exists) return res.status(400).send('name already exists');

  await usersCollection.insertOne(req.body);
  res.send('OK');
});

/* =========================
   Server
========================= */
const port = process.env.USER_SERVER_PORT || 8080;
app.listen(port, () => {
  logger.info(`User service started on port ${port}`);
});
