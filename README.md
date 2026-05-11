# 🤖 Robots Shop - Microservices Architecture Demo

> A comprehensive microservices e-commerce platform showcasing modern cloud-native architecture with **5 deployment strategies**: Docker Compose, Kubernetes, Helm, ArgoCD, and Terraform.

![Deployment Methods](https://img.shields.io/badge/Deployments-5-blue) ![Services](https://img.shields.io/badge/Services-8-green) ![Languages](https://img.shields.io/badge/Languages-5-orange) ![Databases](https://img.shields.io/badge/Databases-4-red)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Deployment Methods](#-deployment-methods)
  - [Docker Compose](#1-docker-compose)
  - [Kubernetes Manifests](#2-kubernetes-manifests)
  - [Helm Charts](#3-helm-charts)
  - [ArgoCD GitOps](#4-argocd-gitops)
  - [Terraform Infrastructure](#5-terraform-infrastructure)
- [Monitoring & Observability](#-monitoring--observability)
- [Load Generation](#-load-generation)
- [Configuration Reference](#-configuration-reference)
- [Development](#-development)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

**Robots Shop** is an educational microservices e-commerce platform designed to demonstrate:

✅ **Modern Architecture Patterns**
- Microservices decomposition
- Service-to-service communication
- Asynchronous messaging patterns
- Data consistency strategies

✅ **Cloud-Native Technologies**
- Containerization (Docker)
- Container orchestration (Kubernetes)
- Infrastructure as Code (Helm)
- GitOps (ArgoCD)

✅ **Production-Grade Features**
- Health checks & auto-healing
- Horizontal Pod Autoscaling (HPA)
- Distributed monitoring (Prometheus)
- Alert management

✅ **Multi-Language Stack**
- Node.js (Frontend & Backend)
- Python (Payment Processing)
- Java (Shipping Service)
- Go (Dispatch Service)
- PHP (Ratings)

**⚠️ Note**: This is a **demo/educational project**. Security hardening and production-level error handling are minimal.

---

## 🏗️ Architecture

### System Components Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                          Load Balancer                         │
└────────────────────────┬─────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
     ┌──▼──┐         ┌───▼───┐       ┌───▼────┐
     │ Web │         │Catalog│       │ Cart   │
     │(Nginx)        │(Node) │       │(Node)  │
     └─────┘         └───┬───┘       └────┬───┘
                         │                 │
        ┌────────────────┼─────┬──────────┘
        │                │     │
     ┌──▼──┐         ┌───▼─┐ ┌▼────┐
     │User │         │Pay  │ │Ratings
     │(Node)         │(Py) │ │(PHP)
     └─┬──┬┘         └──┬──┘ └──┬──┘
       │  │             │       │
   ┌───▼──▼─────────────┼───┬───▼──┐
   │  Data Layer        │   │      │
   │                    │   │      │
   │ MongoDB  MySQL     │   │      │
   │ Redis   RabbitMQ   │   │      │
   └────────────────────┘   │      │
                            │      │
                         ┌──▼───┐ │
                         │Dispatch
                         │(Go)   │
                         └───────┘
```

### Microservices Overview

| Service | Framework | Database | Port | Replicas | Purpose |
|---------|-----------|----------|------|----------|---------|
| **Web** | Nginx | - | 8080 | 1 | Frontend & Reverse Proxy |
| **Catalogue** | Node.js | MongoDB | 8080 | 1-3* | Product Management |
| **Cart** | Node.js | Redis | 8080 | 2-3* | Shopping Cart |
| **User** | Node.js | MongoDB+Redis | 8080 | 1-3* | User Accounts |
| **Shipping** | Java (Spring) | MySQL | 8080 | 1 | Logistics |
| **Ratings** | PHP | MySQL+Redis | 80 | 1-3* | Reviews & Ratings |
| **Payment** | Python (Flask) | RabbitMQ | 8080 | 1 | Payment Processing |
| **Dispatch** | Go | RabbitMQ | 8080 | 1 | Order Fulfillment |

*\*Auto-scaling enabled in Kubernetes deployment (HPA)*

### Data Services

| Service | Type | Port | Purpose |
|---------|------|------|---------|
| **MongoDB** | Document DB | 27017 | Catalogue & User data |
| **MySQL** | Relational DB | 3306 | Ratings & Shipping data |
| **Redis** | Cache/Session | 6379 | Cart & Session storage |
| **RabbitMQ** | Message Broker | 5672 | Async messaging |

---

## 🛠️ Technology Stack

### Backend Services
- **Node.js** + Express.js
- **Python** 3.8+ with Flask
- **Java** 11+ with Spring Boot
- **Go** 1.16+
- **PHP** 7.4+

### Frontend
- **Nginx** web server
- **AngularJS** 1.x
- HTML5 / CSS3

### Databases & Messaging
- **MongoDB** 5.0+ (NoSQL)
- **MySQL** 8.0+ (RDBMS)
- **Redis** 6.0+ (Cache)
- **RabbitMQ** 3.8+ (Message Broker)

### Container & Orchestration
- **Docker** (Multi-stage builds)
- **Kubernetes** 1.20+
- **Helm** 3.0+
- **ArgoCD** (GitOps)

### Monitoring & Observability
- **Prometheus** (Metrics)
- **Grafana** (Dashboards)
- **PrometheusRules** (Alerts)
- **ServiceMonitor** (Auto-discovery)

---

## 📁 Project Structure

```
Robots-Shop/
│
├── 📄 README.md                          # This file
├── 📄 CONFIGURATION_REFERENCE.md         # All environment variables
├── 📄 PROJECT_SUMMARY.md                 # Quick reference
├── 📄 DEPENDENCY_MAP.md                  # Service dependencies
│
├── 🐳 services/                          # Microservices code
│   ├── web/                              # Frontend (Nginx)
│   ├── catalogue/                        # Product service (Node.js)
│   ├── cart/                             # Cart service (Node.js)
│   ├── user/                             # User service (Node.js)
│   ├── shipping/                         # Shipping (Java)
│   ├── ratings/                          # Ratings (PHP)
│   ├── payment/                          # Payment (Python)
│   └── dispatch/                         # Dispatch (Go)
│
├── 📦 infra/                             # Infrastructure as Code
│   ├── docker-compose/
│   │   ├── docker-compose.yaml           # All services
│   │   ├── docker-compose-loadgen.yaml   # Load generation
│   │   └── .env                          # Environment variables
│   ├── k8s/                              # Raw Kubernetes manifests
│   │   ├── cart/deployment.yaml
│   │   ├── catalogue/
│   │   └── ... (all services)
│   ├── helm/                             # Helm Chart
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/                    # K8s templates
│   │       ├── apps-deployment.yaml
│   │       ├── apps-hpa.yaml
│   │       ├── apps-service.yaml
│   │       ├── apps-servicemonitor.yaml
│   │       ├── mongodb-*
│   │       ├── mysql-*
│   │       ├── rabbitmq-*
│   │       └── ingress.yaml
│   └── db-init/                          # Database initialization
│       ├── mongo/init.js
│       └── mysql/init.sql
│
├── 🔍 monitoring/                        # Observability
│   ├── values.yaml                       # Prometheus stack config
│   ├── alerts/                           # Alert rules
│   │   ├── mongo-alerts.yaml
│   │   ├── mysql-alerts.yaml
│   │   ├── rabbitmq-alerts.yaml
│   │   └── redis-alerts.yaml
│   └── dashboards/                       # Grafana dashboards
│       ├── business-dashboard.json
│       └── mysql.json
│
├── 📊 load-gen/                          # Load testing
│   ├── robot-shop.py                     # Locust test scenarios
│   ├── load-gen.sh
│   ├── Dockerfile
│   └── requirements.txt
│
├── 🔄 argocd/                            # GitOps automation
│   ├── robots-app.yaml                   # Main app deployment
│   └── monitoring-app.yaml               # Monitoring stack
│
└── 🐙 .github/                           # GitHub workflows
    └── workflows/
```

---

## 📋 Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 4 GB | 8+ GB |
| **Disk** | 10 GB | 20+ GB |
| **Network** | Standard | Gigabit |

### Required Tools

- **Docker** 20.10+ ([Install](https://docs.docker.com/install/))
- **Docker Compose** 2.0+ ([Install](https://docs.docker.com/compose/install/))
- **kubectl** 1.20+ ([Install](https://kubernetes.io/docs/tasks/tools/))
- **Helm** 3.0+ ([Install](https://helm.sh/docs/intro/install/))
- **Git** 2.0+ ([Install](https://git-scm.com/))

### Optional Tools

- **Minikube** or **kind** (Local Kubernetes)
- **Azure CLI** (Azure AKS)
- **Lens** (Kubernetes IDE)

### Environment Setup

```bash
# Clone the repository
git clone https://github.com/MahmoudG27/Robots-Shop.git
cd Robots-Shop

# Set permissions
chmod +x load-gen/*.sh

# Verify Docker installation
docker --version
docker-compose --version

# Verify Kubernetes tools
kubectl version --client
helm version
```

---

## 🚀 Deployment Methods

The project supports **5 different deployment strategies**:

### 1. Docker Compose

Best for: **Local Development**, Quick Testing, Learning

#### Quick Start

```bash
# Navigate to infrastructure
cd infra/docker-compose

# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f web

# Stop services
docker-compose down
```

#### Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Web UI | `http://localhost:8080` | Application frontend |
| Catalogue API | `http://localhost:8080/catalogue` | Product API |
| Cart API | `http://localhost:8080/cart` | Cart operations |
| Metrics (Cart) | `http://localhost:8080/metrics` | Prometheus metrics |

#### Configuration

Customize deployment via `docker-compose/.env`:

```bash
# Image registry
IMAGE_REGISTRY=containerregistryrobots.azurecr.io
IMAGE_TAG=v1.0.0

# Database credentials
MONGO_USER=admin
MONGO_PASS=admin123
MYSQL_ROOT_PASS=rootpass
MYSQL_USER=shipping
MYSQL_PASS=shipping123
```

#### Enable Load Generation

```bash
# Start separate load generation container
docker-compose -f docker-compose.yaml -f docker-compose-loadgen.yaml up -d

# Configure load via environment
docker-compose logs loadgen
```

---

### 2. Kubernetes Manifests

Best for: **Manual Control**, Understanding K8s, Production Debugging

#### Prerequisites

```bash
# Have a Kubernetes cluster running
# Local: minikube, kind, Docker Desktop
# Cloud: AKS, EKS, GKE

# Verify cluster access
kubectl cluster-info
kubectl get nodes
```

#### Deployment

```bash
# Create namespace
kubectl create namespace robot-shop

# Deploy databases (required first)
kubectl apply -f infra/k8s/mongo/ -n robot-shop
kubectl apply -f infra/k8s/mysql/ -n robot-shop
kubectl apply -f infra/k8s/redis/ -n robot-shop
kubectl apply -f infra/k8s/rabbitMQ/ -n robot-shop

# Wait for databases to be ready
kubectl wait --for=condition=ready pod -l app=mongo -n robot-shop --timeout=300s

# Deploy applications
kubectl apply -f infra/k8s/ -n robot-shop

# Verify deployment
kubectl get pods -n robot-shop
kubectl get svc -n robot-shop
```

#### Access Application

```bash
# Port forward to web service
kubectl port-forward svc/web 8080:8080 -n robot-shop

# Access via browser
# http://localhost:8080
```

#### Scaling & Monitoring

```bash
# Scale a service
kubectl scale deployment catalogue --replicas=3 -n robot-shop

# View pod logs
kubectl logs -f deployment/cart -n robot-shop

# Monitor resource usage
kubectl top pods -n robot-shop
```

#### Cleanup

```bash
kubectl delete namespace robot-shop
```

---

### 3. Helm Charts

Best for: **Production Deployments**, Customization, Version Management

#### Installation

```bash
# Add Helm chart repository (if applicable)
helm repo add robotshop https://charts.example.com

# Create namespace
kubectl create namespace robot-shop

# Deploy using Helm
helm install robot-shop ./infra/helm \
  --namespace robot-shop \
  --values infra/helm/values.yaml

# Verify installation
helm list -n robot-shop
kubectl get all -n robot-shop
```

#### Customization

Override default values:

```bash
# Update specific values
helm upgrade robot-shop ./infra/helm \
  --namespace robot-shop \
  --set services.replicas=3 \
  --set services.resources.limits.cpu=500m
```

Create custom `values-prod.yaml`:

```yaml
# values-prod.yaml
global:
  namespace: robot-shop
  imageTag: "v1.0.0"

services:
  defaults:
    replicas: 3
    resources:
      requests:
        cpu: 250m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi

  cart:
    replicas: 3
    hpa:
      enabled: true
      maxReplicas: 10

  catalogue:
    hpa:
      enabled: true
```

Deploy with custom values:

```bash
helm upgrade robot-shop ./infra/helm \
  --namespace robot-shop \
  -f infra/helm/values.yaml \
  -f values-prod.yaml
```

#### Useful Helm Commands

```bash
# Check what would be deployed
helm template robot-shop ./infra/helm -n robot-shop

# Get deployment values
helm get values robot-shop -n robot-shop

# Rollback to previous version
helm rollback robot-shop -n robot-shop

# Uninstall
helm uninstall robot-shop -n robot-shop
```

---

### 4. ArgoCD (GitOps)

Best for: **Automated Deployments**, Multi-Environment, CD/CI Pipeline

#### Prerequisites

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get initial admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d
```

#### Access ArgoCD UI

```bash
# Port forward to ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8443:443

# Access UI: https://localhost:8443
# Username: admin
# Password: (from secret above)
```

#### Deploy Application

```bash
# Apply ArgoCD application manifests
kubectl apply -f argocd/robots-app.yaml -n argocd

# Monitor sync status
argocd app get robot-shop

# Check in UI or via CLI
argocd app list
```

#### Application Configuration

File: `argocd/robots-app.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: robot-shop
  namespace: argocd

spec:
  project: default

  source:
    repoURL: https://github.com/MahmoudG27/Robots-Shop.git
    targetRevision: master
    path: infra/helm

  destination:
    server: https://kubernetes.default.svc
    namespace: default

  syncPolicy:
    automated:
      prune: true        # Delete resources not in Git
      selfHeal: true     # Auto-sync when cluster drifts
```

#### Git Workflow

```bash
# Make changes locally
vim infra/helm/values.yaml

# Commit and push
git add .
git commit -m "Update replica count"
git push origin master

# ArgoCD auto-syncs (if automated: true)
# Or manually sync:
argocd app sync robot-shop
```

#### Monitoring Deployments

```bash
# View deployment history
argocd app history robot-shop

# Compare with Git
argocd app diff robot-shop

# Get detailed app status
argocd app get robot-shop --refresh
```

---

### 5. Terraform Infrastructure

Best for: **Automated Azure infrastructure provisioning**, consistent staging/production environments, and reusable resource definitions.

#### What Terraform deploys

The Terraform configuration in `infra/terraform/` provisions the Azure infrastructure required for the Robot Shop stack, including:

- Resource Group
- Virtual Network and Subnets
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Azure SQL / MSSQL Server
- Application Gateway
- Key Vault
- Log Analytics Workspace
- NAT Gateway
- Virtual Machine agent
- VPN Gateway
- DNS resources

#### Project Structure

```
infra/terraform/
├── main.tf
├── provider.tf
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── prod/
└── modules/
    ├── ACR/
    ├── AKS/
    ├── AppGw/
    ├── DNS/
    ├── KeyVault/
    ├── LogAnalytics/
    ├── MSSQL/
    ├── NAT/
    ├── Network/
    ├── ResourceGroup/
    ├── VM/
    └── VPN/
```

#### Quick Start

```bash
cd infra/terraform
terraform init
terraform workspace select dev || terraform workspace new dev
terraform plan -var-file=./environments/dev/terraform.tfvars
terraform apply -var-file=./environments/dev/terraform.tfvars
```

#### Customize environment

- Use `infra/terraform/environments/dev/terraform.tfvars` to change Azure resource names, CIDR ranges, AKS sizes, and service settings.
- Create a new environment folder under `environments/` if needed.

#### Notes

- `provider.tf` configures the Azure RM provider and subscription.
- `main.tf` references reusable modules for AKS, ACR, networking, database, and security.
- `terraform.tfvars` contains environment-specific values such as resource group name, region, and VM configuration.
- The AKS module depends on NAT and networking modules to provision a secure cluster environment.

#### Cleanup

```bash
terraform destroy -var-file=./environments/dev/terraform.tfvars
```

---

## 📊 Monitoring & Observability

### Prometheus Metrics

The application exports metrics on multiple endpoints:

#### Service Metrics

| Service | Endpoint | Metrics |
|---------|----------|---------|
| **Cart** | `/metrics` | `cart_item_*`, latency histograms |
| **Payment** | `/metrics` | `payment_*`, success/failure counters |
| **Catalogue** | `/metrics` | `catalogue_*`, response times |

#### Database Metrics

| Database | Exporter | Interval | Metrics |
|----------|----------|----------|---------|
| MongoDB | Prometheus Exporter | 15s | Operations, connections, memory |
| MySQL | Prometheus Exporter | 15s | Queries, connections, replication |
| Redis | Redis Exporter | 15s | Commands, memory, evictions |
| RabbitMQ | RabbitMQ Exporter | 15s | Messages, connections, queues |

### Grafana Dashboards

#### Available Dashboards

1. **Business Dashboard** (`business-dashboard.json`)
   - Orders per minute
   - Revenue trends
   - User activity
   - Error rates

2. **MySQL Dashboard** (`mysql.json`)
   - Query performance
   - Replication status
   - Connection pool

#### Access Grafana

```bash
# Default credentials
# Username: admin
# Password: (set during deployment)

# Port forward
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

# Access: http://localhost:3000
```

### Alert Rules

Configured in `monitoring/alerts/`:

#### MongoDB Alerts
- Slow queries detected
- Connection pool exhausted
- Replication lag

#### MySQL Alerts
- Slave replication down
- Slow queries
- Connection limit reached

#### RabbitMQ Alerts
- Queue depth critical
- Channel closed
- Memory usage high

#### Redis Alerts
- Memory fragmentation high
- Evictions detected
- Connection refused

### Query Prometheus Metrics

```bash
# Port forward Prometheus
kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring

# Query examples
# http://localhost:9090/graph

# Instant queries
up{job="kubernetes-apiservers"}

# Range queries
rate(http_requests_total[5m])

# Aggregation
sum(rate(cart_items_total[1m]))
```

---

## ⚡ Load Generation

Generate realistic traffic to test the system:

### Quick Start

```bash
cd load-gen

# Build the image
./build.sh

# Run load generation (default: 1 client)
./load-gen.sh

# Configure load
./load-gen.sh \
  -h http://localhost:8080 \
  -n 10 \
  -t 30m \
  -r 2
```

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `TARGET_HOST` | http://web:8080 | Application URL |
| `NUM_CLIENTS` | 1 | Concurrent users |
| `SPAWN_RATE` | 1 | Users spawned/second |
| `RUN_TIME` | 1h | Duration to run |
| `ERROR` | 0 | Inject errors (1=yes) |
| `SILENT` | 0 | Suppress verbose output |

### Kubernetes Deployment

```bash
# Deploy load generator pod
kubectl apply -f infra/k8s/load-gen/deployment.yaml -n robot-shop

# Monitor load generation
kubectl logs -f deployment/load-gen -n robot-shop

# Adjust scaling during load
# Varies load over time for realistic testing
./load-gen.sh -h http://web:8080 -n 10 -t 1h30m
```

### Performance Monitoring During Load

```bash
# Monitor in parallel terminal
watch kubectl top pods -n robot-shop

# Check auto-scaling
kubectl get hpa -n robot-shop -w

# View metrics in Prometheus
# http://localhost:9090/graph
# Query: rate(http_requests_total[1m])
```

---

## ⚙️ Configuration Reference

For detailed configuration of all services, see [CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md).

### Quick Reference

#### Database Credentials

```
MongoDB:  admin / admin123
MySQL:    shipping / shipping123
          ratings / ratings123
RabbitMQ: guest / guest (docker-compose)
          robotshop / S3cureP@ss! (Kubernetes)
```

#### Service Ports

```
Web:         8080
Catalogue:   8080
Cart:        8080
User:        8080
Shipping:    8080
Ratings:     80
Payment:     8080
Dispatch:    8080
Prometheus:  9090
Grafana:     3000
```

#### Resource Limits (Kubernetes)

```yaml
Requests:
  CPU:     100m
  Memory:  128Mi

Limits:
  CPU:     300m
  Memory:  256Mi

(Shipping service: higher limits due to Java/Spring)
```

---

## 👨‍💻 Development

### Local Development Setup

```bash
# Install Node.js dependencies (for Node services)
cd services/catalogue
npm install

# Install Python dependencies
cd services/payment
pip install -r requirements.txt

# Build individual services
docker build -t robots/catalogue:dev services/catalogue/
```

### Adding New Services

1. Create service directory: `services/myservice/`
2. Add Dockerfile with multi-stage build
3. Create K8s deployment manifest: `infra/k8s/myservice/`
4. Update Helm templates: `infra/helm/templates/`
5. Add to docker-compose.yaml
6. Update monitoring service monitor

### Testing Locally

```bash
# Run docker-compose
docker-compose -f infra/docker-compose/docker-compose.yaml up

# Test endpoints
curl http://localhost:8080/

# Test individual services
curl http://localhost:8080/catalogue/api/catalogue

# Load test
cd load-gen && ./load-gen.sh
```

---

## 🔧 Troubleshooting

### Docker Compose Issues

```bash
# Containers won't start
docker-compose logs <service>

# Port already in use
lsof -i :8080
docker-compose down  # Clean shutdown

# Rebuild images
docker-compose build --no-cache
```

### Kubernetes Issues

```bash
# Pods not starting
kubectl describe pod <pod-name> -n robot-shop

# Check resource constraints
kubectl top nodes
kubectl top pods -n robot-shop

# View recent events
kubectl get events -n robot-shop --sort-by='.lastTimestamp'

# Debug pod
kubectl exec -it <pod-name> -n robot-shop -- /bin/sh
kubectl port-forward pod/<pod-name> 8080:8080 -n robot-shop
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Connection refused | Service not ready | `kubectl wait --for=condition=ready pod` |
| ImagePullBackOff | Registry auth | `kubectl create secret docker-registry` |
| OOMKilled | Memory limit | Increase `limits.memory` in values |
| High latency | Resource contention | Enable HPA or scale replicas |

### Performance Tuning

```bash
# Enable horizontal pod autoscaling
kubectl apply -f infra/k8s/hpa/

# Check HPA status
kubectl get hpa -n robot-shop -w

# Monitor resource usage
watch 'kubectl top pods -n robot-shop; echo "---"; kubectl top nodes'
```

---

## 📚 Additional Resources

### Documentation

- [CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md) - All environment variables
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Quick reference guide
- [DEPENDENCY_MAP.md](DEPENDENCY_MAP.md) - Service interdependencies

### External Links

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Prometheus Docs](https://prometheus.io/docs/)
- [Express.js Guide](http://expressjs.com/)
- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Go Documentation](https://golang.org/doc/)

### Learning Path

1. **Beginners**: Start with Docker Compose
2. **Intermediate**: Learn Kubernetes basics with raw manifests
3. **Advanced**: Use Helm for templating and ArgoCD for GitOps
4. **Expert**: Customize monitoring, add services, implement advanced patterns

---

## 📝 License

This is an educational project. Modify and use as needed for learning.

---

## 👤 Author

**Mahmoud Gamal**

Contributions and feedback are welcome!

---

## 🎉 Quick Links

- 🐳 [Docker Compose Quick Start](#1-docker-compose)
- ☸️ [Kubernetes Quick Start](#2-kubernetes-manifests)
- 📦 [Helm Quick Start](#3-helm-charts)
- 🔄 [ArgoCD Quick Start](#4-argocd-gitops)
- 📊 [Monitoring Setup](#-monitoring--observability)