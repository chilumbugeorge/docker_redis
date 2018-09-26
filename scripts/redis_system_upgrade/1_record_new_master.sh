#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ -e /opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt ]
then
    #del=$(sudo echo > /opt/Docker/upgrade/master_ip.txt)
     del=$(rm /opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt);
     t=$(touch /opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt);
     c=$(chmod 666 /opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt);
    echo -e "Check file ${GREEN}/opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt ${NC}for IPs for new Redis masters after failover"
else
    C=$(touch /opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt);
    X=$(chmod 666 /opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt);
    echo -e "File ${GREEN}/opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt ${NC}created with IPs for new Redis masters after failover"
fi

declare -A containers
while IFS== read -r key value; do
    containers[$key]=${value}
    V=$(docker exec -t $key cat /etc/redis/sentinel.conf |grep "No such");
    if [[ "$V" != "" ]]; then
        echo -e $key ":${BLUE} /etc/redis/sentinel.conf ${NC}does not exist"
    else
        role=$(docker exec -t $key awk '{for(i=1;i<=NF;i++) if ($i ~ /^redis-/) print $(i+1)}' /etc/redis/sentinel.conf | head -1);
        echo "$key=${role}" >>  /opt/docker_redis/scripts/redis_system_upgrade/master_ip.txt
        echo "$key=${role}"
    fi
done < "/opt/docker_redis/scripts/redis_system_upgrade/containers.txt"
exit
