#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

declare -A containers

# Stop each docker container, followed by a removal.
while IFS== read -r key value; do
    containers[$key]=${value}
    CS=$(docker ps -a |grep $key);
    if [[ "$CS" != "" ]]; then
        stop_container=$(docker stop $key);
        remove_container=$(docker rm $key);
        echo "Stopped:" $stop_container
        echo "Removed:" $remove_container
        printf "\n"
    else
       echo "Container $key does not exists"
    fi   
done < "/opt/docker_redis/scripts/redis_system_upgrade/containers.txt"
printf "\n"
echo -e "${GREEN}************************************************************************************************************"
echo -e "${NC}Please!!!, Now you can ${RED}MANUALLY ${NC}perform required upgrades e.g., OS, Kernell, Docker Engine etc. "
echo -e "${NC}Perform the ${RED}Manual Upgrade ${NC}before continuing with the remaining steps "
echo -e "${BLUE}************************************************************************************************************${NC}"
printf "\n"
exit
