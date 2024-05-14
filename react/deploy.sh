#!/bin/bash

# Automate the image build and deployment process
docker compose -f ./compose.yaml down
docker compose -f ./compose.yaml up -d --pull always