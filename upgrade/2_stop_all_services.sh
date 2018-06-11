#!/bin/bash
declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
    reset=$(sudo docker exec -t $key redis-cli -p 26379 sentinel reset '*');
    S=$(sudo docker top $key | grep redis-sentinel | awk '{print $2}'| cut -d. -f1,2,3,4|sort -u);
    R=$(sudo docker top $key | grep redis-server | awk '{print $2}'| cut -d. -f1,2,3,4|sort -u);
    X=$(sudo docker top $key | grep redis_exporter | awk '{print $2}'| cut -d. -f1,2,3,4|sort -u);
    SK=$(sudo kill $S);  
    RK=$(sudo kill $R);
    XK=$(sudo kill $X);
    echo $key ": Sentinel Reset '*':" $reset
    echo -e $key " ${BLUE}SENTINEL ${NC} pid $SK Killed [Ok]";
    echo -e $key " ${GREEN}REDIS  ${NC}pid $RK Killed [Ok]";
    echo -e $key " ${GREEN}REDIS_EXPORTER  ${NC}pid $XK Killed [Ok]";
    printf "\n"
done < "/opt/Docker/upgrade/files/containers.txt"
exit
