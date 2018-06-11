#!/bin/bash
nc -z 127.0.0.1 6379
echo `date`
if [ "$?" -ne 0 ]; then
    echo "Cannot connect to redis."
    exit 2
else
    C=$(redis-cli -p 6379 -h 127.0.0.1 ping | grep "PONG");
    R=$(redis-cli -p 6379 -h 127.0.0.1 role | grep "slave");
    if [[ "$C" != *"PONG"* ]]; then
        echo "loading the dataset in memory"
        exit 2
    fi
    if [[ "$R" != *"slave"* ]]; then
        curl -s --upload-file /etc/consul.d/scripts/master.json http://127.0.0.1:8500/v1/agent/service/register
        redis-cli config set save ""
        echo "Redis is in master mode."
        exit 0
    else
        S=$(redis-cli -p 6379 -h 127.0.0.1 info | grep master_sync_in_progress);
         if [[ "$S" != *"master_sync_in_progress:0"* ]]; then
             curl -s --upload-file /etc/consul.d/scripts/slave.json http://127.0.0.1:8500/v1/agent/service/register
             echo "Redis not yet Synced"
             exit 2
    else
             curl -s --upload-file /etc/consul.d/scripts/slave.json http://127.0.0.1:8500/v1/agent/service/register
             echo "Redis is in slave mode"
             exit 0
         fi
    fi
fi
