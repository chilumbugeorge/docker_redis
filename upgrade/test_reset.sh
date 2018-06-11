#!/bin/bash
declare -A containers

printf "\n"
while IFS== read -r key value; do
    containers[$key]=${value}
    reset=$(sudo docker exec -t $key redis-cli -p 26379 sentinel reset '*');
    echo $key ": Sentinel Reset '*':" $reset
    printf "\n"
done < "/opt/Docker/upgrade/files/containers.txt"
exit
