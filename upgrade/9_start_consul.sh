#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "\n"
echo -e "${RED}MANUALLY hit CTL C ${NC}and run this script again til you cannot enter CTL C anymore."

declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
    X=$(uuidgen | awk '{print tolower($0)}')
    C=$(sudo docker exec -t $key consul agent -node-id $X -config-dir /etc/consul.d/ -bind ${value} &)
    CP=$(sudo docker exec -t $key ps -ef |grep consul);
    echo $i ":" ${GREEN}$CP${NC};
    printf "\n"
    echo -e "${RED}MANUALLY hit CTL C ${NC}and run this script again til you cannot enter CTL C anymore."
done < "/opt/Docker/upgrade/files/containers.txt"
exit
