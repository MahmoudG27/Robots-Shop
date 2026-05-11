# 📋 جدول التكوينات والمتغيرات (Configuration Reference)

## جدول شامل لجميع المتغيرات البيئية

### Web Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | الملاحظة |
|--------|------------------------|--------------|---------|
| CART_HOST | cart | cart | Internal service name |
| CATALOGUE_HOST | catalogue | catalogue | Internal service name |
| USER_HOST | user | user | Internal service name |
| PAYMENT_HOST | payment | payment | Internal service name |
| SHIPPING_HOST | shipping | shipping | Internal service name |
| RATINGS_HOST | ratings | ratings | Internal service name |

### Catalogue Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | Source |
|--------|------------------------|--------------|--------|
| NODE_ENV | production | production | Config |
| MONGO_URL | mongodb://admin:admin123@mongo:27017/catalogue?authSource=admin | From secret + values | Connection string |
| CATALOGUE_SERVER_PORT | 8080 | 8080 | Config |
| GO_SLOW | 0 | 0 | Simulation flag |

### Cart Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | Source |
|--------|------------------------|--------------|--------|
| NODE_ENV | production | production | Config |
| REDIS_HOST | redis | redis | Config |
| CATALOGUE_HOST | catalogue | catalogue | Config |
| CART_SERVER_PORT | 8080 | 8080 | Config |

### User Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | Source |
|--------|------------------------|--------------|--------|
| NODE_ENV | production | production | Config |
| MONGO_URL | mongodb://admin:admin123@mongo:27017/users?authSource=admin | From secret + values | Connection string |
| REDIS_HOST | redis | redis | Config |
| REDIS_PORT | 6379 | 6379 | Config |

### Shipping Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | Source |
|--------|------------------------|--------------|--------|
| DB_HOST | mysql | mysql | Config |
| DB_PORT | 3306 | 3306 | Config |
| DB_NAME | cities | cities | Config |
| DB_USER | shipping | shipping | Config |
| DB_PASSWORD | shipping123 | From secret | Secret reference |
| CART_ENDPOINT | http://cart:8080 | cart | Service reference |
| JAVA_OPTS | - | -XX:MaxRAMPercentage=75.0 -XX:+TieredCompilation | JVM tuning |

### Payment Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | Source |
|--------|------------------------|--------------|--------|
| CART_HOST | cart | cart | Config |
| CART_PORT | 8080 | 8080 | Config |
| USER_HOST | user | user | Config |
| USER_PORT | 8080 | 8080 | Config |
| AMQP_HOST | rabbitmq | rabbitmq | Config |
| AMQP_PORT | 5672 | 5672 | Config |
| AMQP_USER | guest | From secret | Secret reference |
| AMQP_PASS | guest | From secret | Secret reference |
| PAYMENT_GATEWAY | https://sandbox.paypal.com/ | https://paypal.com/ | Config |
| PAYMENT_DELAY_MS | 0 | 0 | Config |

### Ratings Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | Source |
|--------|------------------------|--------------|--------|
| REDIS_HOST | redis | redis | Config |
| REDIS_PORT | 6379 | 6379 | Config |
| MYSQL_HOST | mysql | mysql | Config |
| MYSQL_PORT | 3306 | 3306 | Config |
| MYSQL_DB | ratings | ratings | Config |
| MYSQL_USER | ratings | ratings | Config |
| MYSQL_PASSWORD | ratings123 | From secret | Secret reference |
| CATALOGUE_URL | http://catalogue:8080 | http://catalogue:8080 | Config |

### Dispatch Service
| متغير | القيمة (docker-compose) | القيمة (Helm) | Source |
|--------|------------------------|--------------|--------|
| AMQP_HOST | rabbitmq | rabbitmq | Config |
| AMQP_PORT | 5672 | 5672 | Config |
| AMQP_USER | guest | From secret | Secret reference |
| AMQP_PASS | guest | From secret | Secret reference |
| DISPATCH_ERROR_PERCENT | 0 | 0 | Config |

---

## MongoDB Configuration

### Connection Parameters
| Parameter | Value | Note |
|-----------|-------|------|
| Host | mongo / mongodb | Service name |
| Port | 27017 | Default MongoDB port |
| Auth Source | admin | Authentication database |
| Username | admin | Root user |
| Password | admin123 | Default password |

### Databases
| Database | Purpose | Collections |
|----------|---------|------------|
| catalogue | Product catalog | products |
| users | User data | users |

### Default Data
```
Database: catalogue
Collection: products
Documents:
{
  sku: "ABC123",
  name: "Robot Arm",
  price: 100,
  instock: 10
},
{
  sku: "XYZ789",
  name: "Robot Head",
  price: 50,
  instock: 5
},
{
  sku: "LMN456",
  name: "Robot Wheel",
  price: 25,
  instock: 20
}

Database: users
Collection: users
Documents:
{
  username: "user",
  password: "password"
}
```

---

## MySQL Configuration

### Root Access
| Parameter | Value |
|-----------|-------|
| Username | root |
| Password | root / rootpass123 |
| Host | mysql |
| Port | 3306 |

### Application Users

#### Shipping User
| Parameter | Value |
|-----------|-------|
| Username | shipping |
| Password | shipping123 |
| Privileges | ALL PRIVILEGES on cities.* |
| Database | cities |

#### Ratings User
| Parameter | Value |
|-----------|-------|
| Username | ratings |
| Password | ratings123 |
| Privileges | ALL PRIVILEGES on ratings.* |
| Database | ratings |

#### Exporter User
| Parameter | Value |
|-----------|-------|
| Username | exporter |
| Password | exporter |
| Privileges | PROCESS, REPLICATION CLIENT, SELECT on *.* |
| Purpose | Prometheus monitoring |

### Databases

#### cities
```sql
-- For Shipping service
-- Stores city/location data for shipping calculations
-- Created by: mysql-init-job-shipping.yaml
```

#### ratings
```sql
-- For Ratings service
CREATE TABLE ratings (
  sku VARCHAR(80) NOT NULL PRIMARY KEY,
  avg_rating DECIMAL(3,2) NOT NULL,
  rating_count INT NOT NULL
) ENGINE=InnoDB;
```

---

## Redis Configuration

| Parameter | Value |
|-----------|-------|
| Host | redis |
| Port | 6379 |
| Database | 0 (default) |
| Authentication | None (default) |

### Usage by Services
- **Cart**: Session/cache storage
- **User**: Session/cache storage  
- **Ratings**: Cache storage

---

## RabbitMQ Configuration

### docker-compose
| Parameter | Value |
|-----------|-------|
| Host | rabbitmq |
| Port (AMQP) | 5672 |
| Username | guest |
| Password | guest |
| Management UI | rabbitmq:15672 |

### Kubernetes (from secrets)
| Parameter | Value |
|-----------|-------|
| Host | rabbitmq |
| Port (AMQP) | 5672 |
| Username | robotshop |
| Password | S3cureP@ss! |
| Management UI | rabbitmq:15672 |

### Message Flows
| From | To | Queue | Purpose |
|------|----|----- |---------|
| Payment | RabbitMQ | orders | Order events |
| Dispatch | RabbitMQ | orders | Consume orders |

---

## Grafana Configuration

| Parameter | Value |
|-----------|-------|
| Service Name | monitoring-grafana |
| Namespace | monitoring |
| Admin User | admin |
| Admin Password | admin123 |
| Port | 3000 |
| Access Method | http://localhost:3000 (after port-forward) |
| Persistence | 5Gi (enabled) |
| Datasource | http://monitoring-kube-prometheus-prometheus:9090 |

### Default Dashboards Enabled
- Kubernetes cluster monitoring
- Prometheus stats
- AlertManager status

### Custom Dashboards
- business-dashboard.json (business metrics)
- mysql.json (MySQL-specific metrics)

---

## Prometheus Configuration

| Parameter | Value |
|-----------|-------|
| Service Name | monitoring-kube-prometheus-prometheus |
| Namespace | monitoring |
| Port | 9090 |
| Storage | 10Gi |
| Retention | 7 days |
| CPU | 200m request, 500m limit |
| Memory | 400Mi request, 800Mi limit |

### Scrape Targets
- kube-state-metrics (k8s state)
- node-exporter (node metrics)
- cAdvisor (container metrics)
- ServiceMonitors (app metrics)

---

## Resource Limits (Helm Values)

### Defaults (per service)
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 300m |
| Memory | 128Mi | 256Mi |

### Overrides

#### Shipping
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 500m | 1000m |
| Memory | 512Mi | 1024Mi |

#### MongoDB
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 200m | 500m |
| Memory | 512Mi | 1Gi |

#### MySQL
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 500m | 2000m |
| Memory | 1Gi | 2Gi |

#### Redis
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 200m |
| Memory | 128Mi | 256Mi |

#### RabbitMQ
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 500m | 1000m |
| Memory | 1Gi | 1.5Gi |

#### Prometheus
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 200m | 500m |
| Memory | 400Mi | 800Mi |

#### AlertManager
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 200m |
| Memory | 100Mi | 200Mi |

---

## Health Check Endpoints

### HTTP GET Probes

| Service | Path | Type | Period | Initial Delay |
|---------|------|------|--------|--------------|
| Cart | /health/live | Liveness | 20s | 10s |
| Cart | /health/ready | Readiness | 10s | 10s |
| Catalogue | /health/live | Liveness | 20s | 10s |
| Catalogue | /health/ready | Readiness | 10s | 10s |
| User | /health/live | Liveness | 20s | 10s |
| User | /health/ready | Readiness | 10s | 10s |
| Payment | /health/live | Liveness | 20s | 10s |
| Payment | /health/ready | Readiness | 10s | 10s |
| Dispatch | /health/live | Liveness | 20s | 10s |
| Dispatch | /health/ready | Readiness | 10s | 10s |
| Ratings | /_health | Liveness | 20s | 10s |
| Ratings | /_health | Readiness | 10s | 10s |

### Exec Probes (MongoDB, Shipping)

#### MongoDB
```bash
mongosh --eval "db.adminCommand('ping')"
```
| Type | Initial Delay | Period |
|------|--------------|--------|
| Liveness | 20s | 10s |
| Readiness | 10s | 5s |

#### Shipping
```
/actuator/health/liveness
/actuator/health/readiness
```
| Type | Initial Delay | Period |
|------|--------------|--------|
| Liveness | 80s | 20s |
| Readiness | 5s | 10s |
| Startup | 30s (custom) | - |

---

## Load Generation Configuration

| Parameter | Value | Note |
|-----------|-------|------|
| Host | http://web:8080 | Target application |
| Num Clients | 50 | Concurrent users |
| Run Time | 10m | Duration |
| Silent | 0 | Verbose output |
| Error | 0 | Error injection (0-100%) |
| Tool | Locust (Python) | Load testing framework |

---

## Docker Registry

| Parameter | Value |
|-----------|-------|
| Registry | containerregistryrobots.azurecr.io |
| Repository Prefix | robots / containerregistryrobots |
| Image Tag | v1.0.0 |
| Namespace | (not used, push directly to registry) |

### Image Names
```
containerregistryrobots.azurecr.io/web:v1.0.0
containerregistryrobots.azurecr.io/catalogue:v1.0.0
containerregistryrobots.azurecr.io/cart:v1.0.0
containerregistryrobots.azurecr.io/user:v1.0.0
containerregistryrobots.azurecr.io/shipping:v1.0.0
containerregistryrobots.azurecr.io/ratings:v1.0.0
containerregistryrobots.azurecr.io/payment:v1.0.0
containerregistryrobots.azurecr.io/dispatch:v1.0.0
containerregistryrobots.azurecr.io/load-gen:v1.0.0
containerregistryrobots.azurecr.io/mysql:v1.0.0
```

---

## Git Configuration (ArgoCD)

| Parameter | Value |
|-----------|-------|
| Repository URL | https://github.com/MahmoudG27/Robots-Shop.git |
| Branch | master |
| App Path | infra/helm |
| Sync Policy | Automated with auto-heal |
| Prune | Enabled |

---

## Kubernetes Namespace

| Item | Value | Namespace |
|------|-------|-----------|
| Application | robot-shop | default |
| Monitoring | Prometheus + Grafana | monitoring |
| Ingress Controller | nginx (implied) | ingress-nginx |
| ArgoCD | ArgoCD applications | argocd |

---

## Storage Classes

| Item | Storage Class | Access Mode | Size |
|------|--------------|-------------|------|
| MongoDB | standard | ReadWriteOnce | 5Gi |
| MySQL | standard | ReadWriteOnce | 10Gi |
| Redis | standard | ReadWriteOnce | 2Gi |
| RabbitMQ | standard | ReadWriteOnce | 1Gi (default) |
| Prometheus | standard | ReadWriteOnce | 10Gi |
| AlertManager | standard | ReadWriteOnce | 2Gi |
| Grafana | standard | ReadWriteOnce | 5Gi |

---

## Secrets (base64 encoded in K8s)

### mongo-secret
```yaml
MONGO_INITDB_ROOT_USERNAME: YWRtaW4= (admin)
MONGO_INITDB_ROOT_PASSWORD: cGFzc3dvcmQ= (password)
```

### mysql-secret
```yaml
root-password: rootpass123
shipping-password: shipping123
ratings-password: ratings123
```

### rabbitmq-secret
```yaml
RABBITMQ_DEFAULT_USER: robotshop
RABBITMQ_DEFAULT_PASS: S3cureP@ss!
```

---

## Horizontal Pod Autoscaler (HPA)

### Enabled Services
| Service | Min Replicas | Max Replicas | CPU Target |
|---------|-------------|-------------|-----------|
| Cart | 1 | 3 | 70% |
| Catalogue | 1 | 3 | 70% |
| Ratings | 1 | 3 | 70% |

### Disabled Services
- Shipping (requires high memory/CPU stability)
- Dispatch (async/event-driven)
- Payment (critical path)
- User (shared state with Redis)
- Web (usually 1 replica sufficient)

---

## Service Monitor Configuration

### Scrape Interval
| Service | Path | Interval | Port |
|---------|------|----------|------|
| Cart | /metrics | 15s | http |
| Catalogue | /metrics | 15s | http |
| Dispatch | /metrics | 15s | http |
| Payment | /metrics | 15s | http |
| Ratings | /metrics | 15s | http |
| Shipping | /actuator/prometheus | 15s | http |

---

## Alert Rules Summary

| Component | Alert Name | Condition | Severity | Duration |
|-----------|-----------|-----------|----------|----------|
| MongoDB | MongoHighConnections | current > 100 | Warning | 2m |
| MongoDB | MongoDown | exporter down | Critical | 1m |
| MySQL | MySQLHighConnections | connections > 80% max | Warning | 2m |
| MySQL | MySQLTooManyRunningThreads | threads > 20 | Warning | 2m |
| MySQL | MySQLSlowQueriesHigh | rate > 5/5m | Critical | 2m |
| MySQL | MySQLHighDiskReads | rate > 10/5m | Warning | 2m |
| MySQL | MySQLHighTempTables | rate > 5/5m | Warning | 2m |
| MySQL | MySQLDown | exporter down | Critical | 1m |
| Redis | RedisHighMemory | used > 90% | Warning | 2m |
| Redis | RedisEvictions | rate > 0 | Critical | 1m |
| RabbitMQ | RabbitMQQueueHigh | messages > 100 | Warning | 2m |
| RabbitMQ | RabbitMQNoConsumers | consumers == 0 | Critical | 1m |

---

**تم التحديث**: 11 May 2026
