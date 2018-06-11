#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
    role=$(sudo docker exec -t $key redis-cli role | head -1);
    echo $key ":" $role
done < "/opt/Docker/upgrade/files/containers.txt"
printf "\n"
echo -e "${BLUE}PLEASE!!! ${NC}Perform ${GREEN}Master Failover ${NC}Appropriately"
exit
