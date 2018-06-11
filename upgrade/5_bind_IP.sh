declare -A containers

while IFS== read -r key value; do
    containers[$key]=${value}
    IP=$(sudo pipework eth3 $key ${value//[[:blank:]]/}/23@10.7.1.254);
    echo $key "bound to" ${value//[[:blank:]]/}/23@10.7.1.254 
done < "/opt/Docker/upgrade/files/containers.txt"
exit
