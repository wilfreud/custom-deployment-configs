#!/bin/bash
# This deployment script file is used to automate the image build and deployment process depending on the branch argument provided.
# The branch argument being for example 'dev' or 'main' or 'feature-branch' etc. Useful for CI/CD pipelines.
# Call the script inside of github-actions-custom.yaml file like this: ./custom-deploy.sh ${{ github.ref }}
# Checkout github-actions-custom.yaml file for more details.
set -e

# 
# Check if branch argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <branch>"
  exit 1
fi

BRANCH=$1

if [ "$BRANCH" == "dev" ]; then
  COMPOSE_FILE="compose-dev.yaml"
else
  COMPOSE_FILE="compose.yaml"
fi

echo "Using Compose file: $COMPOSE_FILE"

# Quote variables to handle spaces or special characters
docker compose -f "$COMPOSE_FILE" down --remove-orphans
docker compose -f "$COMPOSE_FILE" up -d --build --pull always