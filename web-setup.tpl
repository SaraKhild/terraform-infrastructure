#!/bin/bash

sudo apt-get update -yy
sudo apt-get install -yy git curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

docker run -d \
    -p 5000:5000 \
    --name web_app \
    -e REDIS_HOST="${redis_host}" \
    -e DB_HOST="${db_host}" \
    -e DB_USER="user" \
    -e DB_PASSWORD="password" \
    -e DB_NAME="mydatabase" \
    sarakalhussain/devops:latest