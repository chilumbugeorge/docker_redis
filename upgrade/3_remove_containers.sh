#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
    S=$(sudo docker stop $key);
    R=$(sudo docker rm $key);
    echo "Stopped:" $S
    echo "Removed:" $R
    printf "\n"
done < "/opt/Docker/upgrade/files/containers.txt"
printf "\n"
echo -e "${GREEN}************************************************************************************************************"
echo -e "${NC}Please!!!, Now you can ${RED}MANUALLY ${NC}perform required upgrades e.g., OS, Kernell, Docker Engine etc. "
echo -e "${NC}Perform the ${RED}Manual Upgrade ${NC}before continuing with the remaining steps "
echo -e "${BLUE}************************************************************************************************************${NC}"
printf "\n"
exit
