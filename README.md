# Stan's Robot Shop - Microservices on Azure AKS

A sample microservices e-commerce application deployed on Azure Kubernetes Service (AKS) with Prometheus monitoring. This project demonstrates containerized application orchestration, microservices architecture, and cloud-native monitoring techniques.

## 📋 Overview

Stan's Robot Shop is a complete microservices platform showcasing modern cloud-native development practices. Each service is independently deployable and uses its own technology stack. The application is instrumented with Prometheus for comprehensive observability.

**Note**: This is a sandbox application for learning. Error handling is basic and security features are minimal - not intended for production use.

## 🏗️ Architecture

### Microservices

| Service | Technology | Port | Purpose |
|---------|-----------|------|---------|
| **Web** | Nginx + AngularJS 1.x | 8080 | Frontend UI & Reverse Proxy |
| **Catalogue** | Node.js + Express + MongoDB | 8080 | Product catalog management |
| **Cart** | Node.js + Express + Redis | 8080 | Shopping cart operations |
| **User** | Node.js + Express + MongoDB + Redis | 8080 | User authentication & profiles |
| **Shipping** | Java + Spring Boot + MySQL | 8080 | Shipping calculation & management |
| **Ratings** | PHP + Apache + MySQL | 80 | Product ratings & reviews |
| **Payment** | Python + Flask + RabbitMQ | 8080 | Payment processing |
| **Dispatch** | Go + RabbitMQ | 8080 | Order dispatch & fulfillment |

### Data Services

- **MongoDB** - Document store for catalogue and user data
- **MySQL** - Relational database for ratings and shipping data
- **Redis** - In-memory cache for cart and sessions
- **RabbitMQ** - Message broker for asynchronous operations

### Monitoring

- **Prometheus** - Metrics collection and time-series database
- **Service Metrics** - `/metrics` endpoint on Node.js and Python services

## 📦 Directory Structure

```
Robots Microservices/
├── catalogue/                  # Product catalogue service (Node.js)
├── cart/                       # Shopping cart service (Node.js)
├── user/                       # User service (Node.js)
├── shipping/                   # Shipping service (Java Spring Boot)
├── ratings/                    # Ratings service (PHP)
├── payment/                    # Payment service (Python Flask)
├── dispatch/                   # Order dispatch service (Go)
├── web/                        # Frontend UI (Nginx + AngularJS)
├── load-gen/                   # Load testing tools (Python Locust)
├── mysql/                      # MySQL database initialization
├── Manifests/                  # Kubernetes deployment manifests
│   ├── cart/
│   ├── catalogue/
│   ├── dispatch/
│   ├── mongo/
│   ├── mysql/
│   ├── payment/
│   ├── rabbitMQ/
│   ├── ratings/
│   ├── redis/
│   ├── shipping/
│   ├── user/
│   └── web/
├── docker-compose.yaml         # Local development setup
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites

- **Azure Account** with AKS cluster (or local K8s with minikube)
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager (optional, for advanced deployments)
- **Docker** - For local building and testing
- **Azure CLI** - For managing Azure resources


### Deploy to Azure AKS

#### 1. Prepare Azure Resources

```bash
# Set variables
RESOURCE_GROUP="robot-shop-rg"
CLUSTER_NAME="robot-shop-aks"
REGISTRY_NAME="robotshopacr"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
az acr create --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME --sku Basic

# Create AKS Cluster
az aks create --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --enable-managed-identity \
  --network-plugin azure \
  --network-policy azure
```

#### 2. Configure kubectl Access

```bash
# Get AKS credentials
az aks get-credentials --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME --overwrite-existing

# Verify connection
kubectl cluster-info
kubectl get nodes
```

#### 3. Build and Push Images to Registry

```bash
# Login to ACR
az acr login --name $REGISTRY_NAME

# Build images
docker-compose build

# Tag and push images
docker tag robotshop/rs-web:latest $REGISTRY_NAME.azurecr.io/robotshop/rs-web:latest
docker push $REGISTRY_NAME.azurecr.io/robotshop/rs-web:latest

# Repeat for all services...
```

#### 4. Deploy to AKS

```bash
# Create namespace
kubectl create namespace robot-shop

# Update image references in Manifests (if using ACR)
# Change image registry from Docker Hub to your ACR

# Deploy services
kubectl apply -f Manifests/ -n robot-shop

# Verify deployments
kubectl get deployments -n robot-shop
kubectl get pods -n robot-shop
kubectl get svc -n robot-shop
```

#### 5. Access the Application

```bash
# Get external IP of web service
kubectl get svc web -n robot-shop

# Access application
# http://<EXTERNAL-IP>:8080
```

## 📊 Monitoring with Prometheus

### Service Metrics Endpoints

| Service | Endpoint | Metrics |
|---------|----------|---------|
| Cart | `http://cart:8080/metrics` | Items added counter |
| Payment | `http://payment:8080/metrics` | Purchase counter, cart histograms |
```

### Load Gen Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `TARGET_HOST` | Application URL | `http://web:8080` |
| `NUM_CLIENTS` | Concurrent clients | `10` |
| `SPAWN_RATE` | Client spawn rate | `2` |
| `RUN_TIME` | Duration to run (seconds) | `3600` |
| `ERROR_RATE` | Inject error percentage | `5` |


## 📚 Learning Resources

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Prometheus Operator Documentation](https://prometheus-operator.dev/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Express.js Guide](http://expressjs.com/)
- [Flask Documentation](https://flask.palletsprojects.com/)

```

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                    Azure AKS                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────────────────────────────────┐   │
│  │            Ingress / Load Balancer       │   │
│  └────────────────────┬─────────────────────┘   │
│                       │                         │
│  ┌────────────┬───────▼────────┬──────────┐     │
│  │   Web      │   Catalogue    │  Cart    │     │
│  │ (Nginx)    │   (Node.js)    │(Node.js) │     │
│  └────────┬───┴────────────────┴──────────┘     │
│           │                                     │
│  ┌────────▼─────┬──────────┬──────────────┐     │
│  │    User      │  Payment │  Dispatch    │     │
│  │  (Node.js)   │ (Python) │    (Go)      │     │
│  └──────────────┴──────────┴──────────────┘     │
│                                                 │
│  ┌──────────────────────────────────────────┐   │
│  │       Data Services & Messaging          │   │
│  │  MongoDB  │  MySQL  │  Redis │ RabbitMQ  │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  ┌──────────────────────────────────────────┐   │
│  │        Prometheus Monitoring             │   │
│  │      (Metrics Scraping & Storage)        │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 👤 Author

**Mahmoud Gamal**

---

For issues, feature requests, or contributions, please refer to the repository

kind load docker-image containerregistryrobots.azurecr.io/web:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/user:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/shipping:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/cart:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/catalogue:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/dispatch:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/payment:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/ratings:v1.0.0
kind load docker-image containerregistryrobots.azurecr.io/load-gen:v1.0.0


docker build -t containerregistryrobots.azurecr.io/web:v1.0.0 ./web -f web/Dockerfile
docker build -t containerregistryrobots.azurecr.io/user:v1.0.0 ./user -f user/Dockerfile
docker build -t containerregistryrobots.azurecr.io/shipping:v1.0.0 ./shipping -f shipping/Dockerfile
docker build -t containerregistryrobots.azurecr.io/cart:v1.0.0 ./cart -f cart/Dockerfile
docker build -t containerregistryrobots.azurecr.io/catalogue:v1.0.0 ./catalogue -f catalogue/Dockerfile
docker build -t containerregistryrobots.azurecr.io/dispatch:v1.0.0 ./dispatch -f dispatch/Dockerfile
docker build -t containerregistryrobots.azurecr.io/payment:v1.0.0 ./payment -f payment/Dockerfile
docker build -t containerregistryrobots.azurecr.io/ratings:v1.0.0 ./ratings -f ratings/Dockerfile
docker build -t containerregistryrobots.azurecr.io/load-gen:v1.0.0 ./load-gen -f load-gen/Dockerfile