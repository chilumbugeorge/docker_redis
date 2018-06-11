#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
    N=$(sudo docker exec -t $key sysctl net.core.somaxconn);
    R=$(sudo docker exec -t $key service redis-server start);
    RS=$(sudo docker exec -t $key service rsyslog start);
    S=$(sudo docker exec -t $key service redis-sentinel start);
    RED=$(sudo docker exec -t $key ps -ef |grep redis-server);
    sleep 5
    SEN=$(sudo docker exec -t $key ps -ef |grep redis-sentinel);
    RSPS=$(sudo docker exec -t $key ps -ef |grep rsyslog);

    echo $key ":" $RED;
    echo $key ":" $SEN;
    echo $key ":" $RSPS;
    echo $key ":" $N;
    printf "\n"
    echo -e "${BLUE}SLEEPING FOR 30 SECONDS......${NC}"
    sleep 30
done < "/opt/Docker/upgrade/files/containers.txt"
