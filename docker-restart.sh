#!/bin/bash

# Stop and remove all running containers
echo "Stopping and removing all running containers..."
docker-compose down

echo "Forcefully stopping and removing all containers..."
docker stop $(docker ps -q) 2>/dev/null

docker rm $(docker ps -aq) 2>/dev/null

# Remove all Docker images
echo "Removing all Docker images..."
docker rmi $(docker images -q) -f 2>/dev/null

# Remove all Docker volumes
echo "Removing all Docker volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

# Prune unused Docker resources
echo "Pruning unused Docker resources..."
docker system prune -a -f

# Rebuild and restart Docker Compose setup
echo "Rebuilding and restarting Docker Compose setup..."
docker-compose up --build

echo "Docker Compose setup restarted successfully."
