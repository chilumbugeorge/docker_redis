#!/bin/bash 
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}It will take a few minutes for image to be created, so please wait...${NC}"
set -x 
C=$(docker build --no-cache=true --tag redis:4.0.11.1 /opt/docker_redis/);
