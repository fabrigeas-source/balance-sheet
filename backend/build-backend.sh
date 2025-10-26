#!/bin/bash
# Build backend Docker image and start with pm2
set -e

cd "$(dirname "$0")"

# Build Docker image
docker build -t balance-sheet-backend:latest .

# Stop and remove old container if exists
pm2 delete balance-sheet-backend || true

# Start new container with pm2
pm2 start npm --name balance-sheet-backend -- run start

echo "Backend Docker image built and started with pm2."
