#!/usr/bin/env bash
let count=`grep student_count terraform.tfvars | awk '{print $3}'`
idx=0
for i in `seq $count`; do
  echo -n "Student$i: "
  terraform state show azurerm_public_ip.ctrl_eip[$idx]  |  grep ip_address | grep -v allocation|  awk '{print $3}'
  ((idx++))
done
let count=`grep server_count terraform.tfvars | awk '{print $3}'`
idx=0
for i in `seq $count`; do
  echo -n "Server$i: "
  terraform state show azurerm_network_interface.master_nic[$idx] | grep private_ip_address | head -1 | awk '{print $3}'
  ((idx++))
done
echo -n "Jumpbox: "
terraform state show azurerm_public_ip.jumpbox_eip  |  grep ip_address | grep -v allocation|  awk '{print $3}'
echo -n "Jumpbox [private]: "
terraform state show azurerm_network_interface.jumpbox_nic | grep private_ip_address | head -1 | awk '{print $3}'
