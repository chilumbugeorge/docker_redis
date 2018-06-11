#!/bin/bash

declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
    C=$(sudo docker run -td -i -d -v /srv/${key//[[:blank:]]/}:/opt/redis -v /proc:/writable-proc --sysctl net.core.somaxconn=4096 --hostname $key --name $key redis:4.0.9 bash)
    echo $key "Container created:" $C
done < "/opt/Docker/upgrade/files/containers.txt"
exit
