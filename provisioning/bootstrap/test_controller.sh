#!/bin/bash

jumpbox=`redis-cli keys '*_jumpbox'`
user=`redis-cli hget $jumpbox 'Lab_avi_backup_admin_username'`
pass=`redis-cli hget $jumpbox 'Lab_avi_backup_admin_password'`

for k in `redis-cli keys '*_controller'`; do
  for n in `redis-cli hget $k 'Lab_Name'`; do
    echo "-=Controller ${n}=-"
    curl -k -X POST -c cookies -d "username=${user}&password=${pass}" https://${n}/login > /dev/null 2>&1
    curl -k -b cookies -s "https://${n}/api/cloud-inventory?name=AWS&fields=status" | jq '.results[0].status.state'
    echo
  done
done
