#!/bin/bash
declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
     S=$(sudo docker exec -t $key sed -i -e 's/1gb/'${value//[[:blank:]]/}'/g' /etc/redis/redis.conf);
     echo $key ":maxmemory has been updated"
done < "/opt/Docker/upgrade/files/maxmemory.txt"

while IFS== read -r key value; do
    containers[$key]=${value}
     S=$(sudo docker exec -t $key sed -i -e 's/master_ip_address/'${value//[[:blank:]]/}'/g' /etc/redis/sentinel.conf);
     echo $key ":sentine's master_ip_address has been updated appropriately"
done < "/opt/Docker/upgrade/files/master_ip.txt"

while IFS== read -r key value; do
    containers[$key]=${value}
     service=${key::-2}
     SJ=$(sudo docker exec -t $key sed -i -e 's/redis-name/'${service//[[:blank:]]/}'/g' /etc/consul.d/services.json);
     SM=$(sudo docker exec -t $key sed -i -e 's/redis-name/'${service//[[:blank:]]/}'/g' /etc/consul.d/scripts/slave.json);
     SS=$(sudo docker exec -t $key sed -i -e 's/redis-name/'${service//[[:blank:]]/}'/g' /etc/consul.d/scripts/master.json);
     echo $key ":Consul Service updates appropriately"
done < "/opt/Docker/upgrade/files/containers.txt"
