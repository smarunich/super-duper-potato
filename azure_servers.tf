# Terraform definition for the lab Controllers
resource "azurerm_network_interface" "server_nic" {
  count         = "${var.server_count * var.student_count}"
  name                      = "${var.id}_server${floor((count.index / var.student_count % var.server_count)) + 1}.student${count.index % var.student_count + 1}.lab_nic"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.avi_resource_group.name
  network_security_group_id = azurerm_network_security_group.ctrl_sg.id
  ip_configuration {
    name                          =  "${var.id}__server${floor((count.index / var.student_count % var.server_count)) + 1}.student${count.index % var.student_count + 1}.lab_ip"
    subnet_id                     =  azurerm_subnet.avi_privnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    Owner = var.owner
  }
}

resource "azurerm_virtual_machine" "server" {
  count         =  "${var.server_count * var.student_count}"
  name          = "${var.id}_server${floor((count.index / var.student_count % var.server_count)) + 1}.student${count.index % var.student_count + 1}.lab"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.avi_resource_group.name
  vm_size                   = var.flavour_server
  network_interface_ids     = [ azurerm_network_interface.server_nic[count.index].id ]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-RAW"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.id}_server${floor((count.index / var.student_count % var.server_count)) + 1}.student${count.index % var.student_count + 1}.lab_ssd"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name = "server${floor((count.index / var.student_count % var.server_count)) + 1}.student${count.index % var.student_count + 1}.lab"
    admin_username = var.avi_ssh_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.avi_backup_admin_username}/.ssh/authorized_keys"
      key_data = "${trimspace(tls_private_key.generated_access_key.public_key_openssh)} aviadmin@avinetworks"
    }
  }

  depends_on        = [ null_resource.jumpbox_provisioner ]

  tags = {
    Owner                         = var.owner
    Lab_Group                     = "servers"
    Lab_Name                      = "server${floor((count.index / var.student_count % var.server_count)) + 1}.student${count.index % var.student_count + 1}.lab"
    Lab_Timezone                  = var.lab_timezone
  }
}

resource "azurerm_virtual_machine_extension" "server" {
  count                = "${var.server_count * var.student_count}"
  name                 = "${var.id}_server${floor((count.index / var.student_count % var.server_count)) + 1}.student${count.index % var.student_count + 1}.lab"
  location             = var.location
  resource_group_name  = azurerm_resource_group.avi_resource_group.name
  virtual_machine_name = azurerm_virtual_machine.server[count.index].name
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
    {
        "commandToExecute": "mkdir /root/.ssh && cp /home/aviadmin/.ssh/authorized_keys /root/.ssh/authorized_keys && curl -L http://${azurerm_network_interface.jumpbox_nic.private_ip_address}/provision_vm.sh | bash && cd /usr/local/bin && curl -O http://${azurerm_network_interface.jumpbox_nic.private_ip_address}/register.py && chmod a+x /usr/local/bin/register.py && register.py ${azurerm_network_interface.jumpbox_nic.private_ip_address}"
    }
SETTINGS

  depends_on        = [ null_resource.jumpbox_provisioner ]

  tags = {
    Owner = var.owner
  }
}
