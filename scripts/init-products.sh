#!/bin/bash

set -euo pipefail

PRODUCT_HOST="${PRODUCT_HOST:-localhost}"
PRODUCT_PORT="${PRODUCT_PORT:-3000}"
API_URL="${API_URL:-http://${PRODUCT_HOST}:${PRODUCT_PORT}/api}"
TOKEN="${TOKEN:-}"
MAX_RETRIES="${MAX_RETRIES:-30}"
SLEEP_SECONDS="${SLEEP_SECONDS:-2}"

wait_for_product_service() {
  echo "Waiting for product-service on ${API_URL}/health..."

  for ((i=1; i<=MAX_RETRIES; i++)); do
    if curl -fsS "${API_URL}/health" >/dev/null 2>&1; then
      echo "product-service is ready."
      return 0
    fi

    echo "Attempt ${i}/${MAX_RETRIES} failed, retrying in ${SLEEP_SECONDS}s..."
    sleep "${SLEEP_SECONDS}"
  done

  echo "product-service did not become ready in time."
  exit 1
}

create_product() {
  local name="$1"
  local price="$2"
  local description="$3"
  local stock="$4"

  local curl_args=(
    -fsS
    -X POST "${API_URL}/products"
    -H "Content-Type: application/json"
  )

  if [ -n "${TOKEN}" ]; then
    curl_args+=(-H "Authorization: Bearer ${TOKEN}")
  fi

  curl_args+=(
    -d "{
      \"name\": \"${name}\",
      \"price\": ${price},
      \"description\": \"${description}\",
      \"stock\": ${stock}
    }"
  )

  curl "${curl_args[@]}"
  echo
}

wait_for_product_service

echo "Creating demo products on ${API_URL}..."

create_product "Smartphone Galaxy S21" 899 "Dernier smartphone Samsung avec appareil photo 108MP" 15
create_product "MacBook Pro M1" 1299 "Ordinateur portable Apple avec puce M1" 10
create_product "PS5" 499 "Console de jeu derniere generation" 5
create_product "Ecouteurs AirPods Pro" 249 "Ecouteurs sans fil avec reduction de bruit" 20
create_product "Nintendo Switch" 299 "Console de jeu portable" 12
create_product "iPad Air" 599 "Tablette Apple avec ecran Retina" 8
create_product "Montre connectee" 199 "Montre intelligente avec suivi d'activite" 25
create_product "Enceinte Bluetooth" 79 "Enceinte portable waterproof" 30

echo "Product initialization completed."
