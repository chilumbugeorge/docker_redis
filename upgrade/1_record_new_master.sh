#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ -e /opt/Docker/upgrade/files/master_ip.txt ] 
then
    printf "\n"
    del=$(sudo rm /opt/Docker/upgrade/files/master_ip.txt)
    echo -e "Check file ${GREEN}/opt/Docker/upgrade/files/master_ip.txt ${NC}for IPs for new Redis masters after failover"
else
   echo -e "File ${GREEN}/opt/Docker/upgrade/files/master_ip.txt ${NC}created with IPs for new Redis masters after failover"
fi

declare -A containers
while IFS== read -r key value; do
    containers[$key]=${value}
    role=$(sudo docker exec -t $key awk '{for(i=1;i<=NF;i++) if ($i=="mymaster") print $(i+1)}' /etc/redis/sentinel.conf | head -1);
    echo $key"="$role >> /opt/Docker/upgrade/files/master_ip.txt
    echo $key "=" $role
done < "/opt/Docker/upgrade/files/containers.txt"
printf "\n"
exit
