#!/bin/bash

declare -A containers

# Start redis, sentinel, redis exporter and rsys log services. The rsyslog is required to run consul in a docker container.
while IFS== read -r key value; do
    containers[$key]=${value}
    T=$(echo never > /sys/kernel/mm/transparent_hugepage/enabled);
    V=$(sysctl vm.overcommit_memory=1);
    N=$(docker exec -t $key sysctl net.core.somaxconn);
    start_redis=$(docker exec -t $key service redis-server start);
    start_rsyslog=$(docker exec -t $key service rsyslog start);
    start_sentinel=$(docker exec -t $key service redis-sentinel start);
    start_exporter=$(docker exec -t $key /opt/redis_exporter -redis.addr redis://${key//[[:blank:]]/}:6379 -redis.alias $key > /dev/null 2>&1 &) ;
    sleep 5
    status_redis=$(docker exec -t $key ps -ef |grep redis-server);
    status_sentinel=$(docker exec -t $key ps -ef |grep redis-sentinel);
    status_rsyslog=$(docker exec -t $key ps -ef |grep rsyslog);
    status_exporter=$(docker exec -t $key ps -ef |grep redis_exporter);

    echo $key ":" $status_redis;
    echo $key ":" $status_sentinel;
    echo $key ":" $status_rsyslog;
    echo $key ":" $status_exporter;
    echo $key ":" $N;
    printf "\n"

done < "/opt/docker_redis/scripts/redis_create_new/containers.txt"
