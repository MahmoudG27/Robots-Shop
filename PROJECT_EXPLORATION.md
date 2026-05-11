# 📊 استكشاف شامل لمشروع Robots-Shop

## 📋 نظرة عامة
مشروع **Stan's Robot Shop** هو تطبيق e-commerce قائم على الـ microservices، مكتوب بهدف التعليم والتدريب على:
- معمارية الـ Microservices
- التطوير السحابي Cloud-Native على Azure AKS
- الـ Containerization مع Docker
- التنسيق مع Kubernetes و Helm
- المراقبة والـ Observability مع Prometheus
- CI/CD مع ArgoCD

---

## 🏗️ الخدمات الرئيسية وتكنولوجياتها

### 1. **Web Service** (Frontend)
- **التكنولوجيا**: Nginx (Alpine Linux) + AngularJS 1.x
- **الوظيفة**: واجهة المستخدم والـ Reverse Proxy
- **المنفذ**: 8080
- **الصورة**: `containerregistryrobots.azurecr.io/web:v1.0.0`
- **المتغيرات البيئية**:
  - `CART_HOST=cart`
  - `CATALOGUE_HOST=catalogue`
  - `USER_HOST=user`
  - `PAYMENT_HOST=payment`
  - `SHIPPING_HOST=shipping`
  - `RATINGS_HOST=ratings`

### 2. **Catalogue Service**
- **التكنولوجيا**: Node.js + Express.js + MongoDB
- **الوظيفة**: إدارة كتالوج المنتجات
- **المنفذ**: 8080
- **الصورة**: `containerregistryrobots.azurecr.io/catalogue:v1.0.0`
- **المتغيرات البيئية**:
  ```
  NODE_ENV=production
  MONGO_URL=mongodb://admin:admin123@mongo:27017/catalogue?authSource=admin
  CATALOGUE_SERVER_PORT=8080
  GO_SLOW=0
  ```
- **Dependencies**: Express, MongoDB, Pino (logging), Prometheus client
- **المنتجات الافتراضية**:
  - Robot Arm (SKU: ABC123, $100, 10 stock)
  - Robot Head (SKU: XYZ789, $50, 5 stock)
  - Robot Wheel (SKU: LMN456, $25, 20 stock)

### 3. **Cart Service**
- **التكنولوجيا**: Node.js + Express.js + Redis
- **الوظيفة**: إدارة سلة المشتريات
- **المنفذ**: 8080
- **الصورة**: `containerregistryrobots.azurecr.io/cart:v1.0.0`
- **المتغيرات البيئية**:
  ```
  NODE_ENV=production
  REDIS_HOST=redis
  CATALOGUE_HOST=catalogue
  CART_SERVER_PORT=8080
  ```
- **Dependencies**: Express, Redis, Pino, Prometheus client, Rate limiting
- **مراقبة**: ServiceMonitor مفعل ✓
- **Auto Scaling**: مفعل (Min: 1, Max: 3 pods) ✓
- **عدد النسخ الافتراضي**: 2 replicas

### 4. **User Service**
- **التكنولوجيا**: Node.js + Express.js + MongoDB + Redis
- **الوظيفة**: المصادقة وإدارة بيانات المستخدمين
- **المنفذ**: 8080
- **الصورة**: `containerregistryrobots.azurecr.io/user:v1.0.0`
- **المتغيرات البيئية**:
  ```
  NODE_ENV=production
  MONGO_URL=mongodb://admin:admin123@mongo:27017/users?authSource=admin
  REDIS_HOST=redis
  REDIS_PORT=6379
  ```
- **Dependencies**: Express, MongoDB, Redis, Pino, Prometheus client
- **بيانات افتراضية**: مستخدم واحد (username: "user", password: "password")

### 5. **Shipping Service**
- **التكنولوجيا**: Java 11 + Spring Boot 2.7.18
- **الوظيفة**: حساب الشحن وإدارة الشحنات
- **المنفذ**: 8080
- **الصورة**: `containerregistryrobots.azurecr.io/shipping:v1.0.0`
- **المتغيرات البيئية**:
  ```
  DB_HOST=mysql
  DB_PORT=3306
  DB_NAME=cities
  DB_USER=shipping
  DB_PASSWORD=shipping123
  CART_ENDPOINT=http://cart:8080
  JAVA_OPTS=-XX:MaxRAMPercentage=75.0 -XX:+TieredCompilation
  ```
- **الموارد**:
  - Requests: CPU 500m, Memory 512Mi
  - Limits: CPU 1000m, Memory 1024Mi
- **مراقبة**: `/actuator/prometheus`
- **Health Check**: `/actuator/health/liveness`, `/actuator/health/readiness`

### 6. **Ratings Service**
- **التكنولوجيا**: PHP 7.4 + Apache + MySQL + Redis
- **الوظيفة**: تقييمات وتعليقات المنتجات
- **المنفذ**: 80
- **الصورة**: `containerregistryrobots.azurecr.io/ratings:v1.0.0`
- **المتغيرات البيئية**:
  ```
  REDIS_HOST=redis
  REDIS_PORT=6379
  MYSQL_HOST=mysql
  MYSQL_PORT=3306
  MYSQL_DB=ratings
  MYSQL_USER=ratings
  MYSQL_PASSWORD=ratings123
  CATALOGUE_URL=http://catalogue:8080
  ```
- **PHP Extensions**: Redis, PDO MySQL, OPCache
- **Health Check**: `/_health`

### 7. **Payment Service**
- **التكنولوجيا**: Python 3.9 + Flask + RabbitMQ + uWSGI
- **الوظيفة**: معالجة الدفع
- **المنفذ**: 8080
- **الصورة**: `containerregistryrobots.azurecr.io/payment:v1.0.0`
- **المتغيرات البيئية**:
  ```
  CART_HOST=cart
  CART_PORT=8080
  USER_HOST=user
  USER_PORT=8080
  AMQP_HOST=rabbitmq
  AMQP_PORT=5672
  AMQP_USER=guest
  AMQP_PASS=guest
  PAYMENT_GATEWAY=https://paypal.com/
  PAYMENT_DELAY_MS=0
  ```
- **Requirements**: Flask, uWSGI, Requests, Pika (RabbitMQ), Prometheus client
- **Health Metrics**: Cart counter, Purchase counter, Cart histograms

### 8. **Dispatch Service**
- **التكنولوجيا**: Go 1.23 + RabbitMQ
- **الوظيفة**: تنفيذ الطلبات والتسليم
- **المنفذ**: 8080
- **الصورة**: `containerregistryrobots.azurecr.io/dispatch:v1.0.0`
- **المتغيرات البيئية**:
  ```
  AMQP_HOST=rabbitmq
  AMQP_PORT=5672
  AMQP_USER=guest
  AMQP_PASS=guest
  DISPATCH_ERROR_PERCENT=0
  ```
- **Build**: Multi-stage build (CGO_ENABLED=0, static binary)
- **مراقبة**: ServiceMonitor مفعل ✓

---

## 🗄️ خدمات البيانات

### MongoDB
- **الإصدار**: 7.0
- **الاستخدام**: تخزين catalogue و users
- **بيانات المصادقة**:
  - Username: `admin`
  - Password: `admin123` (مشفرة في secrets)
- **التخزين**: Persistent volume (مطلوب)
- **Helm**: `mongodb-statefulset.yaml`
  - Replicas: 1
  - Storage: 5Gi
  - Resources: CPU 200m-500m, Memory 512Mi-1Gi

### MySQL 8.0
- **الاستخدام**: تخزين ratings و shipping (database: cities)
- **قواعد البيانات**:
  - `cities` - لخدمة الشحن
  - `ratings` - لخدمة التقييمات
- **المستخدمون**:
  ```
  shipping / shipping123     - GRANT ALL ON cities.*
  ratings / ratings123       - GRANT ALL ON ratings.*
  exporter / exporter        - GRANT PROCESS, REPLICATION CLIENT, SELECT
  ```
- **جداول**:
  ```sql
  -- ratings table
  CREATE TABLE ratings (
    sku VARCHAR(80) NOT NULL PRIMARY KEY,
    avg_rating DECIMAL(3,2) NOT NULL,
    rating_count INT NOT NULL
  ) ENGINE=InnoDB;
  ```
- **التخزين**: Persistent volume (مطلوب)
- **Helm**: `mysql-statefulset.yaml`
  - Replicas: 1
  - Storage: 10Gi
  - Resources: CPU 500m-2000m, Memory 1Gi-2Gi

### Redis
- **الإصدار**: Latest
- **الاستخدام**: Cache للـ cart و sessions
- **المستخدمون**:
  - Cart service
  - Ratings service
  - User service
- **Helm**: `redis-statefulset.yaml`
  - Replicas: 1
  - Storage: 2Gi
  - Resources: CPU 100m-200m, Memory 128Mi-256Mi

### RabbitMQ
- **الإصدار**: 3.12
- **الاستخدام**: Message broker للـ Payment و Dispatch
- **بيانات المصادقة**:
  - User: `robotshop` (في secrets) أو `guest`
  - Password: `S3cureP@ss!` (في secrets) أو `guest`
- **الموارد**: CPU 500m-1000m, Memory 1Gi-1.5Gi

---

## 🚀 أنواع الـ Deployment

### 1. **Docker Compose** (التطوير المحلي)
**الملفات**:
- `infra/docker-compose/docker-compose.yaml` - التطبيق الرئيسي
- `infra/docker-compose/docker-compose-loadgen.yaml` - اختبار الحمل

**الميزات**:
- شبكة واحدة: `microservices`
- 8 خدمات تطبيق + 4 خدمات بيانات
- سياسة إعادة التشغيل: `unless-stopped`
- تصاعد Compose: `docker-compose up`
- اختبار الحمل: `docker-compose --profile testing up`

**المتغيرات البيئية**:
- Load Gen: 50 clients لمدة 10 دقائق

---

### 2. **Kubernetes Manifests** (K8s مباشر)
**المسار**: `infra/k8s/`

**المكونات**:
- Deployments لكل خدمة (2 replicas للـ cart)
- StatefulSets للبيانات (MongoDB, MySQL, Redis)
- Services
- ConfigMaps و Secrets
- Health Checks (Liveness, Readiness, Startup)

**مثال - Cart Deployment**:
```yaml
replicas: 2
resources:
  requests: CPU 100m, Memory 128Mi
  limits: CPU 300m, Memory 256Mi
livenessProbe: /health/live (20s interval)
readinessProbe: /health/ready (10s interval)
```

---

### 3. **Helm Chart** (التطبيق المنتجي)
**المسار**: `infra/helm/`

**الملفات الأساسية**:
```
Chart.yaml              # v1.0.0
values.yaml             # التكوينات الافتراضية
templates/
├── apps-deployment.yaml
├── apps-hpa.yaml       # Horizontal Pod Autoscaler
├── apps-service.yaml
├── apps-servicemonitor.yaml
├── ingress.yaml
├── mongodb-statefulset.yaml
├── mongodb-secret.yaml
├── mysql-statefulset.yaml
├── mysql-secret.yaml
├── rabbitmq-secret.yaml
├── redis-statefulset.yaml
└── mysql-init-job-*.yaml
```

**الميزات الرئيسية**:
- **Ingress**: nginx (قابل للتبديل إلى azure-application-gateway)
- **Namespace**: default (قابل للتكوين)
- **Image Tag**: latest (قابل للتكوين)
- **Storage Class**: standard
- **Security Context**: runAsNonRoot: true, runAsUser: 1000

**التكوينات الافتراضية**:
```yaml
# Per Service
replicas: 1
resources:
  requests: CPU 100m, Memory 128Mi
  limits: CPU 300m, Memory 256Mi
probes:
  enabled: true
  startupPath: /health/live
  livenessPath: /health/live
  readinessPath: /health/ready

# Auto Scaling
hpa:
  enabled: false (per service)
  minReplicas: 1
  maxReplicas: 3
  cpuUtilization: 70%

# Service Monitoring
serviceMonitor:
  enabled: false (per service)
  path: /metrics
  interval: 15s
```

**خدمات مع Auto Scaling مفعل**:
- ✓ Cart
- ✓ Catalogue
- ✓ Ratings
- ✓ Shipping (بدون HPA)
- ✓ Dispatch (بدون HPA)

**خدمات مع Monitoring مفعل**:
- ✓ Cart
- ✓ Catalogue
- ✓ Dispatch
- ✓ Payment
- ✓ Ratings
- ✓ Shipping

---

### 4. **ArgoCD** (CI/CD)
**المسار**: `argocd/`

#### Robot Shop Application
**الملف**: `robots-app.yaml`
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: robot-shop
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/MahmoudG27/Robots-Shop.git
    targetRevision: master
    path: infra/helm
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true          # حذف الموارد التي تمت إزالتها
      selfHeal: true       # إعادة المزامنة التلقائية
```

#### Monitoring Application
**الملف**: `monitoring-app.yaml`
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring
  namespace: argocd
spec:
  source:
    repoURL: https://prometheus-community.github.io/helm-charts
    chart: kube-prometheus-stack
    targetRevision: 84.5.0
    helm:
      values: |
        grafana:
          adminUser: admin
          adminPassword: admin123
          persistence:
            enabled: true
            size: 5Gi
        prometheus:
          prometheusSpec:
            retention: 7d
            storage: 10Gi
        alertmanager:
          enabled: true
          storage: 2Gi
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```

---

## 🔐 البيانات الحساسة والتكوينات

### 1. **Secrets في Kubernetes**

#### MongoDB Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mongo-secret
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: YWRtaW4= # admin
  MONGO_INITDB_ROOT_PASSWORD: cGFzc3dvcmQ= # password
```

#### MySQL Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
stringData:
  root-password: rootpass123
  shipping-password: shipping123
  ratings-password: ratings123
```

#### RabbitMQ Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-secret
type: Opaque
stringData:
  RABBITMQ_DEFAULT_USER: robotshop
  RABBITMQ_DEFAULT_PASS: S3cureP@ss!
```

### 2. **متغيرات البيئة الحساسة في docker-compose**

```yaml
# MongoDB
MONGO_INITDB_ROOT_USERNAME: admin
MONGO_INITDB_ROOT_PASSWORD: admin123

# MySQL
MYSQL_ROOT_PASSWORD: root
# Users: shipping/shipping123, ratings/ratings123

# RabbitMQ (docker-compose)
AMQP_USER: guest
AMQP_PASS: guest

# Payment
PAYMENT_GATEWAY: https://sandbox.paypal.com/ (docker-compose)
               ou https://paypal.com/ (Helm)
```

### 3. **بيانات الدخول الافتراضية**

| الخدمة | المستخدم | كلمة المرور | الملاحظات |
|--------|---------|-----------|---------|
| MongoDB | admin | admin123 | عام |
| MongoDB | - | - | في يوم سيتم تغييرها |
| MySQL (root) | root | root / rootpass123 | Admin فقط |
| MySQL (shipping) | shipping | shipping123 | Limited access |
| MySQL (ratings) | ratings | ratings123 | Limited access |
| MySQL (exporter) | exporter | exporter | Read-only |
| RabbitMQ | guest | guest | Docker Compose |
| RabbitMQ | robotshop | S3cureP@ss! | Kubernetes (Secrets) |
| Grafana | admin | admin123 | Default dashboard |
| User Service | user | password | App user (MongoDB) |

### 4. **بيانات PayPal الافتراضية**
- Sandbox: `https://sandbox.paypal.com/`
- Production: `https://paypal.com/`

---

## 📊 معلومات الـ Monitoring

### 1. **Prometheus Stack**
**الإعدادات**:
- **Namespace**: monitoring
- **Storage**: 10Gi (Prometheus) + 2Gi (AlertManager)
- **Retention**: 7 أيام
- **Resources**:
  - Prometheus: CPU 200m-500m, Memory 400Mi-800Mi
  - Grafana: Enabled with persistence (5Gi)
  - AlertManager: Enabled with persistence

### 2. **Service Monitors**

#### ServiceMonitor للتطبيقات
تُفعّل لـ:
- Cart (`/metrics`)
- Catalogue (`/metrics`)
- Dispatch (`/metrics`)
- Payment (`/metrics`)
- Ratings (`/metrics`)
- Shipping (`/actuator/prometheus`)

**الفترة الزمنية**: 15 ثانية

#### ServiceMonitor للبيانات
- MongoDB Exporter
- MySQL Exporter
- Redis Exporter
- RabbitMQ Exporter

### 3. **PrometheusRules (Alerts)**

#### MongoDB Alerts
```yaml
- MongoHighConnections: (current > 100) → Warning
- MongoDown: (exporter down) → Critical
```

#### MySQL Alerts
```yaml
- MySQLHighConnections: (Connections > 80% of max) → Warning
- MySQLTooManyRunningThreads: (threads > 20) → Warning
- MySQLSlowQueriesHigh: (rate > 5/5m) → Critical
- MySQLHighDiskReads: (buffer miss rate > 10/5m) → Warning
- MySQLHighTempTables: (temp tables on disk > 5/5m) → Warning
- MySQLDown: (exporter down) → Critical
```

#### Redis Alerts
```yaml
- RedisHighMemory: (used > 90% of max) → Warning
- RedisEvictions: (eviction rate > 0) → Critical
```

#### RabbitMQ Alerts
```yaml
- RabbitMQQueueHigh: (ready messages > 100) → Warning
- RabbitMQNoConsumers: (consumers == 0) → Critical
```

### 4. **Dashboards**
موجودة في `monitoring/dashboards/`:
- `business-dashboard.json` - متجر متابعة الأعمال
- `mysql.json` - لوحة معلومات MySQL

### 5. **Exporters المدمجة**
- kube-state-metrics ✓
- node-exporter ✓
- cAdvisor (من Prometheus stack) ✓
- metrics-server (لـ HPA) ✓

### 6. **Access Grafana**
```bash
# Port-forward
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 --address 0.0.0.0

# البيانات
# URL: http://localhost:3000
# User: admin
# Pass: admin123
```

---

## 📦 متطلبات المشروع

### 1. **Node.js Services Requirements**

#### Cart Service (`services/cart/package.json`)
```json
{
  "engines": { "node": ">=20.0.0" },
  "dependencies": {
    "axios": "^1.6.7",
    "express": "^4.19.2",
    "redis": "^4.6.13",
    "pino": "^9.0.0",
    "express-pino-logger": "^7.0.0",
    "prom-client": "^15.1.0",
    "express-rate-limit": "^7.4.0"
  }
}
```

#### Catalogue Service (`services/catalogue/package.json`)
```json
{
  "engines": { "node": ">=20.0.0" },
  "dependencies": {
    "express": "^4.19.2",
    "mongodb": "^6.5.0",
    "pino": "^9.0.0",
    "express-pino-logger": "^7.0.0",
    "prom-client": "^15.1.0"
  }
}
```

#### User Service (`services/user/package.json`)
```json
{
  "engines": { "node": ">=20.0.0" },
  "dependencies": {
    "axios": "^1.6.7",
    "express": "^4.19.2",
    "mongodb": "^6.5.0",
    "redis": "^4.6.13",
    "pino": "^9.0.0",
    "express-pino-logger": "^7.0.0",
    "prom-client": "^15.1.0"
  }
}
```

### 2. **Python Service Requirements** (`services/payment/requirements.txt`)
```
uwsgi
Flask
requests
pika
prometheus_client
```

### 3. **Java Service Requirements** (`services/shipping/pom.xml`)
```xml
<!-- Parent -->
spring-boot-starter-parent: 2.7.18

<!-- Dependencies -->
- spring-boot-starter-web
- spring-boot-starter-data-jpa
- spring-boot-starter-actuator
- mysql-connector-j (runtime)

<!-- Java Version -->
Java 11
```

### 4. **Go Service Requirements** (`services/dispatch/go.mod`)
```
go 1.23.0

require:
- github.com/prometheus/client_golang v1.23.2
- github.com/rabbitmq/amqp091-go v1.10.0
```

### 5. **PHP Service Requirements** (`services/ratings/Dockerfile`)
```dockerfile
- PHP 7.4 (Apache)
- PHP Extensions:
  - redis (pecl)
  - pdo_mysql
  - opcache
  - zip
- Composer 2
```

### 6. **Load Generation Requirements** (`load-gen/requirements.txt`)
```
locust
```

---

## 🔧 التكوينات الرئيسية

### Health Check Endpoints

| الخدمة | Liveness | Readiness | Startup |
|--------|----------|-----------|---------|
| Cart | /health/live | /health/ready | /health/live |
| Catalogue | /health/live | /health/ready | /health/live |
| Payment | /health/live | /health/ready | /health/live |
| User | /health/live | /health/ready | /health/live |
| Dispatch | /health/live | /health/ready | /health/live |
| Shipping | /actuator/health/liveness | /actuator/health/readiness | /actuator/health/liveness |
| Ratings | /_health | /_health | /_health |

### Metrics Endpoints

| الخدمة | Metrics Endpoint |
|--------|-----------------|
| Cart | /metrics |
| Catalogue | /metrics |
| Payment | /metrics |
| Dispatch | /metrics |
| Ratings | /metrics (PHP standard) |
| Shipping | /actuator/prometheus |
| MongoDB | via exporter |
| MySQL | via exporter |
| Redis | via exporter |
| RabbitMQ | via exporter |

---

## 🐳 Docker Configuration

### Base Images
```dockerfile
Web:       nginx:1.25-alpine
Catalogue: Node 20 (implied)
Cart:      Node 20 (implied)
User:      Node 20 (implied)
Shipping:  eclipse-temurin:11-jre-alpine (multi-stage)
Ratings:   php:7.4-apache
Payment:   python:3.9-slim
Dispatch:  golang:1.23 (multi-stage, scratch)
MongoDB:   mongo:7.0
MySQL:     mysql:8.0
Redis:     redis:latest
RabbitMQ:  rabbitmq:3.12
Load-Gen:  Python (implied)
```

### Multi-Stage Builds
- **Shipping**: Maven build → JRE alpine
- **Dispatch**: Go build → scratch (minimal)

---

## 📝 بيانات المشروع

### مشروع الأساس
- **الاسم**: Stan's Robot Shop
- **المنطقة**: Azure AKS (قابل للتطبيق محليًا)
- **النسخة**: 1.0.0
- **نوع التطبيق**: Microservices e-commerce
- **صاحب المشروع**: Mahmoud Gamal (MG)
- **الترخيص**: Apache 2.0

### Repository
- **الـ URL**: https://github.com/MahmoudG27/Robots-Shop.git
- **الفرع الرئيسي**: master
- **المسار الرئيسي**: infra/helm

---

## 🔄 سير العمل (Workflow)

### محلي (Local Development)
```bash
# التطبيق
docker-compose up

# مع اختبار الحمل
docker-compose --profile testing up

# اختبار الحمل المنفصل
./load-gen/load-gen.sh
```

### Kubernetes (K8s Cluster)
```bash
# التطبيق المباشر
kubectl apply -f infra/k8s/

# Helm
helm install robot-shop infra/helm -n default

# ArgoCD (الموصى به للإنتاج)
argocd app create robot-shop --file argocd/robots-app.yaml
argocd app create monitoring --file argocd/monitoring-app.yaml
```

### Ingress
- **Endpoint**: `/` (متوجه إلى web service على port 8080)
- **IngressClass**: nginx (أو azure-application-gateway)

---

## 🎯 الملخص

| المقياس | القيمة |
|--------|--------|
| عدد الخدمات | 8 microservices |
| خدمات البيانات | 4 (MongoDB, MySQL, Redis, RabbitMQ) |
| لغات البرمجة | 5 (Node.js, Python, Java, Go, PHP) |
| أنواع الـ Deployment | 4 (docker-compose, k8s, helm, argocd) |
| المنافذ المستخدمة | 8080 (معظم الخدمات)، 80 (Ratings/Nginx) |
| الموارد المطلوبة (Helm) | CPU: 2.1 cores, Memory: 4.5Gi (requests) |
| Storage المطلوب | MongoDB: 5Gi, MySQL: 10Gi, Redis: 2Gi, Prometheus: 10Gi |
| Replicas الافتراضية | 1 (معظم الخدمات)، 2 (Cart) |
| Monitoring | ✓ Prometheus + Grafana + Alerts |
| CI/CD | ✓ ArgoCD (GitOps) |
| Auto Scaling | ✓ HPA (Cart, Catalogue, Ratings) |
| Security | ✓ Secrets, non-root users, resource limits |

---

## ⚠️ ملاحظات الأمان

1. **كلمات المرور الافتراضية**: جميع كلمات المرور في هذا المشروع هي للتدريب فقط - **غير آمنة للإنتاج**
2. **Helm Secrets**: استخدم sealed-secrets أو external-secrets في الإنتاج
3. **Security Context**: runAsNonRoot: true ✓
4. **Network Policies**: يُنصح بإضافتها
5. **RBAC**: يُنصح بتطبيق RBAC في الإنتاج
6. **Image Scanning**: استخدم image scanning tools (Trivy, etc.)
7. **ImagePullSecrets**: ضروري لـ private registry (ACR)

---

**تم الاستكشاف**: 11 May 2026
**تم التوثيق بواسطة**: GitHub Copilot
