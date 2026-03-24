# E-Commerce Microservices

Projet e-commerce base sur une architecture microservices avec :

- un frontend Vue.js
- un service d'authentification Node.js / Express / JWT
- un service produits / panier Node.js / Express / MongoDB
- un service commandes Node.js / Express / MongoDB
- une base MongoDB par microservice

Le projet fournit :

- un environnement de developpement avec `docker-compose.yml`
- un environnement de production locale avec `docker-compose.prod.yml`
- des Dockerfiles multi-stage pour le frontend et les services backend
- une pipeline GitLab CI/CD pour les tests, le build d'images et un scan de securite

## Architecture

Services :

- `frontend` : interface utilisateur Vue.js, servie en dev par Vite et en prod par `server.cjs`
- `auth-service` : inscription, connexion, profil utilisateur, JWT
- `product-service` : catalogue produits et panier
- `order-service` : creation et consultation des commandes
- `auth-mongodb`, `product-mongodb`, `order-mongodb` : bases MongoDB dediees

## Arborescence utile

```text
.
|-- docker-compose.yml
|-- docker-compose.prod.yml
|-- .env.example
|-- .env.prod.example
|-- logs_projet.txt
|-- frontend/
|   |-- Dockerfile
|   |-- Dockerfile.dev
|   |-- build-front.yml
|   `-- server.cjs
|-- services/
|   |-- auth-service/
|   |   |-- Dockerfile
|   |   `-- build-auth.yml
|   |-- product-service/
|   |   |-- Dockerfile
|   |   `-- build-product.yml
|   `-- order-service/
|       |-- Dockerfile
|       `-- build-order.yml
`-- scripts/
    |-- init-products.sh
    |-- run-tests.sh
    |-- setup.sh
    `-- tests.md
```

## Prerequis

- Docker Desktop ou Docker Engine
- Docker Compose plugin
- Git
- Git Bash recommande sous Windows pour les scripts shell

Pour les tests hors Docker :

- Node.js 20 recommande
- npm

## Variables d'environnement

### Developpement

Le projet utilise le fichier [`.env`](./.env).

Modele :

```dotenv
FRONTEND_PORT=8080
AUTH_PORT=3001
PRODUCT_PORT=3000
ORDER_PORT=3002

AUTH_MONGO_PORT=27017
PRODUCT_MONGO_PORT=27018
ORDER_MONGO_PORT=27019

JWT_SECRET=change_me_for_dev
```

Le modele versionnable est dans [`.env.example`](./.env.example).

### Production locale

Le projet utilise le fichier [`.env.prod`](./.env.prod).

Modele :

```dotenv
COMPOSE_PROJECT_NAME=e-commerce-prod

FRONTEND_PORT=8081
AUTH_PORT=3101
PRODUCT_PORT=3100
ORDER_PORT=3102

JWT_SECRET=change_me_for_local_prod
AUTH_MONGODB_URI=mongodb://auth-mongodb:27017/auth
PRODUCT_MONGODB_URI=mongodb://product-mongodb:27017/ecommerce
ORDER_MONGODB_URI=mongodb://order-mongodb:27017/orders

VITE_AUTH_SERVICE_URL=http://auth-service:3001
VITE_PRODUCT_SERVICE_URL=http://product-service:3000
VITE_ORDER_SERVICE_URL=http://order-service:3002
```

Le modele versionnable est dans [`.env.prod.example`](./.env.prod.example).

## Lancer le projet en developpement

Depuis Git Bash :

```bash
cd /c/Users/vto/Documents/project_docker/e-commerce-vue-main
docker compose -f docker-compose.yml up --build
```

Acces :

- frontend : `http://localhost:8080`
- auth-service : `http://localhost:3001`
- product-service : `http://localhost:3000`
- order-service : `http://localhost:3002`

Health checks :

```bash
curl http://localhost:3001/api/health
curl http://localhost:3000/api/health
curl http://localhost:3002/api/health
```

Initialisation des produits :

```bash
bash ./scripts/init-products.sh
```

Arret :

```bash
docker compose -f docker-compose.yml down
```

## Lancer le projet en production locale

La production locale permet de valider la stack de runtime sans toucher a la stack dev.

```bash
cd /c/Users/vto/Documents/project_docker/e-commerce-vue-main
docker compose --env-file .env.prod -f docker-compose.prod.yml up -d --build
```

Acces :

- frontend : `http://localhost:8081`
- auth-service : `http://localhost:3101`
- product-service : `http://localhost:3100`
- order-service : `http://localhost:3102`

Health checks :

```bash
curl http://localhost:3101/api/health
curl http://localhost:3100/api/health
curl http://localhost:3102/api/health
```

Initialisation des produits :

```bash
PRODUCT_PORT=3100 bash ./scripts/init-products.sh
```

Arret :

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml down
```

## Tests

### Backend

Auth service :

```bash
cd services/auth-service
npm install
npm test
```

Product service :

```bash
cd services/product-service
npm install
npm test
npm run lint
```

Order service :

```bash
cd services/order-service
npm install
npm test
```

### Frontend

```bash
cd frontend
npm install
npm run test
npm run test:unit
npm run test:coverage
npm run lint:report || true
```

### Script global

Le projet contient aussi un script global :

```bash
bash ./scripts/run-tests.sh
```

## Tests API manuels

### Auth

Inscription :

```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

Connexion :

```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Produits

Liste des produits :

```bash
curl http://localhost:3000/api/products
```

### Commandes

Recuperer un token dans Git Bash :

```bash
TOKEN=$(curl -s -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  | node -e "let s='';process.stdin.on('data',d=>s+=d);process.stdin.on('end',()=>console.log(JSON.parse(s).token))")
```

Creer une commande :

```bash
curl -X POST http://localhost:3002/api/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "products": [{
      "productId": "ID_PRODUIT",
      "quantity": 1
    }],
    "shippingAddress": {
      "street": "123 Test St",
      "city": "Test City",
      "postalCode": "12345"
    }
  }'
```

Lister les commandes :

```bash
curl http://localhost:3002/api/orders \
  -H "Authorization: Bearer $TOKEN"
```

## Limites actuelles

- `docker-compose.prod.yml` est pense pour une production locale ou un VPS simple avec Docker Compose
- Docker Swarm n'est pas deploye dans l'etat actuel du projet
- la prod publique avec domaine / HTTPS n'est pas incluse par defaut
- la version Mongo utilisee dans les compose est encore `mongo:4.4`

## Livrables

### Logs Git

Le fichier [logs_projet.txt](./logs_projet.txt) doit etre regenere avant le rendu final :

```bash
git log --pretty=format:"%h %ad | %s%d [%an]" --date=short > logs_projet.txt
```

### Branches

Workflow Git minimal present :

- `main`
- `develop`

## Resume rapide

Developpement :

```bash
docker compose -f docker-compose.yml up --build
bash ./scripts/init-products.sh
```

Production locale :

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml up -d --build
PRODUCT_PORT=3100 bash ./scripts/init-products.sh
```

Tests :

```bash
bash ./scripts/run-tests.sh
```
