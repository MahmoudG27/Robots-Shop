# 🗺️ خريطة الاعتماديات (Dependency Map)

## العلاقات بين الخدمات

```
┌─────────────────────────────────────────────────────────────┐
│                      Web Frontend                            │
│                    (Nginx + AngularJS)                       │
└──────┬──────────────────────────────────────────────┬────────┘
       │                                              │
       ├─→ calls ─→ ┌─────────────────┐              │
       │             │   Catalogue     │              │
       │             │  (Node + Mongo) │              │
       │             └─────────────────┘              │
       │                                              │
       ├─→ calls ─→ ┌─────────────────┐              │
       │             │      Cart       │              │
       │             │ (Node + Redis)  │──────────┐   │
       │             └─────────────────┘          │   │
       │                    │                      │   │
       │                    ├─→ calls ──→ Catalogue
       │                    │
       │                    └─→ calls ──→ Payment
       │
       ├─→ calls ─→ ┌─────────────────┐
       │             │      User       │
       │             │ (Node + Mongo   │
       │             │  + Redis)       │
       │             └─────────────────┘
       │
       ├─→ calls ─→ ┌─────────────────┐
       │             │    Payment      │
       │             │ (Python + Flask)│
       │             └────────┬────────┘
       │                      │
       │                      ├─→ calls ──→ Cart
       │                      │
       │                      ├─→ calls ──→ User
       │                      │
       │                      └─→ publishes ──→ RabbitMQ
       │
       ├─→ calls ─→ ┌─────────────────┐
       │             │    Shipping     │
       │             │ (Java + MySQL)  │
       │             └─────────────────┘
       │
       └─→ calls ─→ ┌─────────────────┐
                     │    Ratings      │
                     │ (PHP + MySQL    │
                     │  + Redis)       │
                     └────────┬────────┘
                              │
                              └─→ calls ──→ Catalogue


Dispatch Service (Go + RabbitMQ)
       │
       └─→ consumes ──→ RabbitMQ (from Payment & Shipping)


Data Layer Dependencies:
┌─────────────┐
│   MongoDB   │
└──────┬──────┘
       ├─→ Catalogue ✓
       └─→ User ✓

┌─────────────┐
│    MySQL    │
└──────┬──────┘
       ├─→ Shipping (database: cities) ✓
       └─→ Ratings (database: ratings) ✓

┌─────────────┐
│    Redis    │
└──────┬──────┘
       ├─→ Cart ✓
       ├─→ User ✓
       └─→ Ratings ✓

┌─────────────┐
│  RabbitMQ   │
└──────┬──────┘
       ├─→ Payment (publish) ✓
       └─→ Dispatch (consume) ✓
```

---

## جدول الاستدعاءات (Calls Matrix)

| من | إلى | الملاحظة |
|----|----|---------|
| Web | Catalogue | GET /products |
| Web | Cart | GET/POST cart |
| Web | User | GET/POST user |
| Web | Payment | POST payment |
| Web | Shipping | POST shipping |
| Web | Ratings | GET/POST ratings |
| Cart | Catalogue | GET product details |
| Cart | Payment | Submit order |
| Payment | Cart | GET cart data |
| Payment | User | Verify user |
| Payment | RabbitMQ | Publish order event |
| Dispatch | RabbitMQ | Consume order event |
| Ratings | Catalogue | GET product info |

---

## جدول المنافذ (Ports Used)

```
Internal Ports (Service Names):
================================
Web:        8080
Catalogue:  8080
Cart:       8080
User:       8080
Shipping:   8080
Ratings:    80 (Apache)
Payment:    8080
Dispatch:   8080

Database Ports:
================================
MongoDB:    27017
MySQL:      3306
Redis:      6379
RabbitMQ:   5672 (AMQP)

Monitoring:
================================
Prometheus:     9090
Grafana:        3000 (after port-forward)
AlertManager:   9093
node-exporter:  9100

External Port (Published):
================================
Web/Ingress:    8080 (on host, or 80 with ingress)
```

---

## Database Connections

### MongoDB
```
Connection String (docker-compose):
mongodb://admin:admin123@mongo:27017/catalogue?authSource=admin
mongodb://admin:admin123@mongo:27017/users?authSource=admin

Connection String (Helm):
mongodb://admin:admin123@mongodb:27017/catalogue?authSource=admin
mongodb://admin:admin123@mongodb:27017/users?authSource=admin
```

### MySQL
```
Connection String:
mysql://shipping:shipping123@mysql:3306/cities
mysql://ratings:ratings123@mysql:3306/ratings

Exporter:
mysql://exporter:exporter@mysql:3306
```

### Redis
```
Connection String:
redis://redis:6379/0
```

### RabbitMQ
```
Connection String (docker-compose):
amqp://guest:guest@rabbitmq:5672

Connection String (Kubernetes):
amqp://robotshop:S3cureP@ss!@rabbitmq:5672
```

---

## التخزين (Storage Configuration)

### Persistent Volumes

| الخدمة | الحجم | Access Mode | Storage Class |
|--------|-------|------------|--------------|
| MongoDB | 5Gi | ReadWriteOnce | standard |
| MySQL | 10Gi | ReadWriteOnce | standard |
| Redis | 2Gi | ReadWriteOnce | standard |
| Prometheus | 10Gi | ReadWriteOnce | standard |
| Grafana | 5Gi | ReadWriteOnce | standard |
| AlertManager | 2Gi | ReadWriteOnce | standard |

---

## متغيرات البيئة المشتركة

### Service Discovery (Kubernetes)
```
REDIS_HOST=redis
MONGO_URL=mongodb://admin:admin123@mongodb:27017/...
MYSQL_HOST=mysql
AMQP_HOST=rabbitmq
CART_HOST=cart
CATALOGUE_HOST=catalogue
USER_HOST=user
PAYMENT_HOST=payment
SHIPPING_HOST=shipping
RATINGS_HOST=ratings
```

### Application Configuration
```
NODE_ENV=production
JAVA_OPTS=-XX:MaxRAMPercentage=75.0
APP_ENV=prod
GO_SLOW=0 (Catalogue simulation)
DISPATCH_ERROR_PERCENT=0
PAYMENT_DELAY_MS=0
PAYMENT_GATEWAY=https://paypal.com/
```

### Monitoring
```
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000
METRICS_PORT=8080 (default)
METRICS_PATH=/metrics (or /actuator/prometheus for Shipping)
```

---

## تسلسل بدء التشغيل (Startup Sequence)

### Docker Compose
```
1. Networks created
2. Databases start (MongoDB, MySQL, Redis, RabbitMQ)
   - Waiting for health checks
3. db-init services run (mongo-init, mysql-init)
   - Populate initial data
4. Application services start (Web, Catalogue, Cart, User, Shipping, Ratings, Payment, Dispatch)
   - Connected to databases
5. Load Gen (optional profile) starts when services are ready
```

### Kubernetes
```
1. Namespace created (if not exists)
2. Secrets created (mongo-secret, mysql-secret, rabbitmq-secret)
3. ConfigMaps created (init scripts)
4. Storage Classes assigned
5. PersistentVolumeClaims created
6. StatefulSets start (MongoDB, MySQL, Redis, RabbitMQ)
   - Waiting for liveness/readiness probes
7. Init Jobs run (mysql-init-ratings, mysql-init-shipping, mongo-init)
8. Deployments start (App services)
9. Services created (expose pods)
10. Ingress created (routing)
11. ServiceMonitors created (for Prometheus)
12. HPA objects created (Auto-scaling rules)
```

---

## ملخص الاتصالات

### الاتصالات الداخلية (Internal)
- 8 خدمات تطبيق
- 4 خدمات بيانات
- 21 اتصال من service إلى service
- 8 اتصالات من service إلى database
- 2 اتصالات من service إلى message broker

### الاتصالات الخارجية (External)
- Web: 8080 (port published)
- PayPal: https://paypal.com/ (external API)
- Docker Registry: containerregistryrobots.azurecr.io (ACR)
- GitHub: https://github.com/MahmoudG27/Robots-Shop.git (ArgoCD)
