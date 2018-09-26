#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

declare -A containers

# Stop consul on all containers gracefully before shutting down other services.
while IFS== read -r key value; do
    containers[$key]=${value}
    CS=$(docker exec -t $key ps -ef |grep consul);
    if [[ "$CS" != "" ]]; then
        stop_consul=$(docker exec -t $key consul leave);
        echo $key ":" $stop_consul
    else
        echo "Container $key does not seem to have Consul running"
    fi
done < "/opt/docker_redis/scripts/redis_system_upgrade/containers.txt"

printf "\n"
echo -e "${BLUE}Please wait for sessions in redis to complete after stopping consul... ${NC}"
printf "\n"
sleep 5

# After 1 minute of consul stopping, stop redis, sentinel and redis exporter.
while IFS== read -r key value; do
    containers[$key]=${value}
    status_redis=$(docker exec -t $key ps -ef |grep redis-server);
    status_sentinel=$(docker exec -t $key ps -ef |grep redis-sentinel);
    status_exporter=$(docker exec -t $key ps -ef |grep redis_exporter);
    if [[ "$status_redis" != "" ]]; then
        stop_redis=$(docker exec -t $key pkill redis-server);
        echo $key ":" $stop_redis "Redis Server Stopped."
    else
        echo "Container $key does not seem to have redis-server running"
    fi

    if [[ "$status_sentinel" != "" ]]; then
        stop_sentinel=$(docker exec -t $key pkill redis-sentinel);
        echo $key ":" $stop_sentinel "Redis Sentinel Stopped."
    else
        echo "Container $key does not seem to have redis-sentinel running"
    fi
          
    if [[ "$status_exporter" != "" ]]; then
        stop_exporter=$(docker exec -t $key pkill redis_exporter);
        echo $key ":" $stop_exporter "Redis Exporter Stopped." 
    else
        echo "Container $key does not seem to have redis_exporter running"
    fi 
    printf "\n"
done < "/opt/docker_redis/scripts/redis_system_upgrade/containers.txt"
exit
