#!/bin/bash
set -e

# Configuration
COMPOSE_FILE="./compose.yaml"
DEPLOY_VERSION=$(date +%Y%m%d_%H%M%S)
LOGFILE="deployments.log"
MAX_RETRIES=30
SLEEP_SECONDS=2
BACKUP_DIR="./deployment_backups"

# Ensure backup directory exists
mkdir -p $BACKUP_DIR

# Logging function
log_event() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message"
    echo "$message" >> $LOGFILE
}

# Get current deployment state
get_current_state() {
    log_event "📸 Taking snapshot of current deployment..."
    mkdir -p "$BACKUP_DIR/$DEPLOY_VERSION"
    docker compose -f $COMPOSE_FILE images > "$BACKUP_DIR/$DEPLOY_VERSION/images.txt"
    docker compose -f $COMPOSE_FILE ps > "$BACKUP_DIR/$DEPLOY_VERSION/containers.txt"
    # Save current .env if it exists
    if [ -f .env ]; then
        cp .env "$BACKUP_DIR/$DEPLOY_VERSION/.env.backup"
    fi
}

# Health check function
check_service_health() {
    local counter=0
    log_event "🔍 Starting health checks..."
    
    while [ $counter -lt $MAX_RETRIES ]; do
        if docker compose -f $COMPOSE_FILE ps | grep -q "healthy"; then
            log_event "✅ Services are healthy"
            return 0
        fi
        echo "⏳ Waiting for services to be healthy... (Attempt $counter/$MAX_RETRIES)"
        sleep $SLEEP_SECONDS
        counter=$((counter + 1))
    done
    
    log_event "❌ Health check failed after $MAX_RETRIES attempts"
    return 1
}

# Rollback function
rollback() {
    local exit_code=$?
    log_event "🔄 Deployment failed with exit code $exit_code, initiating rollback..."
    
    # Bring down the failed deployment
    docker compose -f $COMPOSE_FILE down --remove-orphans || true
    
    # Restore from backup if it exists
    if [ -d "$BACKUP_DIR/$DEPLOY_VERSION" ]; then
        if [ -f "$BACKUP_DIR/$DEPLOY_VERSION/.env.backup" ]; then
            cp "$BACKUP_DIR/$DEPLOY_VERSION/.env.backup" .env
        fi
        
        # Pull previous images
        while read -r line; do
            if [[ $line =~ ^[^[:space:]]+ ]]; then
                image=$(echo "$line" | awk '{print $1":"$2}')
                if [ ! -z "$image" ]; then
                    log_event "⏪ Restoring image: $image"
                    docker pull $image || true
                fi
            fi
        done < "$BACKUP_DIR/$DEPLOY_VERSION/images.txt"
        
        # Restart with previous state
        log_event "🔄 Restarting previous deployment..."
        docker compose -f $COMPOSE_FILE up -d --no-pull
        
        log_event "⚠️ Rollback completed. System restored to previous state."
    else
        log_event "❌ No backup found for rollback!"
    fi
    
    exit 1
}

# Set trap for errors
trap rollback ERR

# Start deployment
log_event "🚀 Starting deployment version: $DEPLOY_VERSION"

# Backup current state
get_current_state

# Stop current deployment
log_event "⏹️ Stopping current deployment..."
docker compose -f $COMPOSE_FILE down --remove-orphans || true

# Pull new images
log_event "⬇️ Pulling new images..."
docker compose -f $COMPOSE_FILE pull

# Start new deployment
log_event "▶️ Starting new deployment..."
docker compose -f $COMPOSE_FILE up -d --pull always

# Check service health
check_service_health

# Clean up old images
log_event "🧹 Cleaning up old images..."
docker image prune -f

# Success message
log_event "✅ Deployment $DEPLOY_VERSION completed successfully"

# Keep only last 5 backups
cd $BACKUP_DIR && ls -t | tail -n +6 | xargs rm -rf 2>/dev/null || true