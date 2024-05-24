#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Bring down existing containers
echo "Bringing down existing containers..."
docker compose down || { echo "Failed to bring down containers"; exit 1; }

# Pull the latest images and bring up new containers
echo "Pulling latest images and bringing up new containers..."
docker compose up -d --pull=always || { echo "Failed to bring up containers"; exit 1; }

echo "Deployment completed successfully."
