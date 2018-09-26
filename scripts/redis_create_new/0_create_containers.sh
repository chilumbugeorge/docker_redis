#!/bin/bash

# Help Redis to better manage memory usage.
S=$(echo never > /sys/kernel/mm/transparent_hugepage/enabled);
V=$(sysctl vm.overcommit_memory=1);

declare -A containers
while IFS== read -r key value; do
    containers[$key]=${value}
    service=${key::-2}    
    CS=$(docker ps -a |grep $key);
    if [[ "$CS" != "" ]]; then
        echo "Container $key Already exists"
        exit 2
    else
        cont_create=$(docker run -td -i -d -v /srv/${key//[[:blank:]]/}:/opt/redis -v /proc:/writable-proc --sysctl net.core.somaxconn=4096 --hostname $key --name $key redis:4.0.11.1 bash);
        ip_bind=$(pipework em1 $key ${value//[[:blank:]]/}/24@10.1.24.254);
        service_name=$(docker exec -t $key sed -i -e 's/redis-name/'${service//[[:blank:]]/}'/g' /etc/consul.d/services.json);
        slave_name=$(docker exec -t $key sed -i -e 's/redis-name/'${service//[[:blank:]]/}'/g' /etc/consul.d/scripts/slave.json);
        master_name=$(docker exec -t $key sed -i -e 's/redis-name/'${service//[[:blank:]]/}'/g' /etc/consul.d/scripts/master.json);
        echo $key "Container created:" $cont_create
        echo $key "bound to" ${value//[[:blank:]]/}/24@10.1.24.254 
        echo $key ":Consul config files updated."
        printf "\n"
    fi
done < "/opt/docker_redis/scripts/redis_create_new/containers.txt"

sleep 30
while IFS== read -r key value; do
    containers[$key]=${value}
        maxmemory=$(docker exec -t $key sed -i -e 's/1gb/'${value//[[:blank:]]/}'/g' /etc/redis/redis.conf);
        dump=$(docker exec -t $key mkdir -p /opt/redis/redis_dump);
        perm=$(docker exec -t $key chown redis:redis -R /opt/redis/redis_dump/);
        echo $key ": Redis maxmemory has been updated to" $value
        printf "\n"
done < "/opt/docker_redis/scripts/redis_create_new/maxmemory.txt"

while IFS== read -r key value; do
     containers[$key]=${value}
     mymaster=${key::-2}
     master_ip=$(docker exec -t $key sed -i -e 's/master_ip_address/'${value//[[:blank:]]/}'/g' /etc/redis/sentinel.conf);
     redis_name=$(docker exec -t $key sed -i -e 's/mymaster/'${mymaster//[[:blank:]]/}'/g' /etc/redis/sentinel.conf);
     echo $key ":Sentine's master_ip_address has been updated appropriately to" $value
     echo $key ":Sentinel's mymaster value has been updated appropriately to" $mymaster
     printf "\n"
done < "/opt/docker_redis/scripts/redis_create_new/master_ip.txt"
exit
