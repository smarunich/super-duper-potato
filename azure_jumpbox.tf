# Terraform definition for the lab Controllers

resource "azurerm_public_ip" "jumpbox_eip" {
  name                         =  "${var.id}_jumpbox_eip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.avi_resource_group.name
  allocation_method           = "Dynamic"
  tags = {
    Owner = var.owner
  }
}

# to recapture the data required for provisioner
data "azurerm_public_ip" "jumpbox_eip" {
  name                         =  "${var.id}_jumpbox_eip"
  resource_group_name          = azurerm_resource_group.avi_resource_group.name
}


resource "azurerm_network_interface" "jumpbox_nic" {
  name                         =  "${var.id}_jumpbox_nic"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.avi_resource_group.name
  network_security_group_id = azurerm_network_security_group.jumpbox_sg.id
  ip_configuration {
    name                         =  "${var.id}_jumpbox_ip"
    subnet_id                     =  azurerm_subnet.avi_pubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox_eip.id
  }
  tags = {
    Owner = var.owner
  }
}


resource "azurerm_virtual_machine" "jumpbox" {
  name          = "${var.id}_jumpbox"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.avi_resource_group.name
  vm_size                   = var.flavour_centos
  network_interface_ids     = [ azurerm_network_interface.jumpbox_nic.id ]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

# az vm image list --output table

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-RAW"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.id}_jumpbox_ssd"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    #disk_size_gb      =  var.vol_size_centos
  }


  os_profile {
    computer_name   = "${var.id}-jumpbox"
    admin_username  = var.avi_backup_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.avi_backup_admin_username}/.ssh/authorized_keys"
      key_data = "${trimspace(tls_private_key.generated_access_key.public_key_openssh)} aviadmin@avinetworks"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on        = [tls_private_key.generated_access_key, local_file.aviadmin_pem]


  tags = {
    Owner                         = var.owner
    Lab_Group                     = "jumpbox"
    Lab_Name                      = "jumpbox.student.lab"
    Lab_vnet_id                   = azurerm_virtual_network.avi_vnet.id
    Lab_subscription_id           = var.azure_subscription_id
    Lab_avi_default_password      = var.avi_default_password
    Lab_avi_admin_password        = var.avi_admin_password
    Lab_ocp_oreg_auth_user        = var.ocp_oreg_auth_user
    Lab_ocp_oreg_auth_password    = var.ocp_oreg_auth_password
    Lab_ocp_rhsm_pool_id          = var.ocp_rhsm_pool_id
    Lab_ocp_rhsm_org              = var.ocp_rhsm_org
    Lab_ocp_rhsm_activationkey    = var.ocp_rhsm_activationkey
    Lab_avi_backup_admin_username = var.avi_backup_admin_username
    Lab_avi_backup_admin_password = var.avi_backup_admin_password
    Lab_avi_management_network    = azurerm_subnet.avi_mgmtnet.name 
    Lab_avi_vip_network           = azurerm_subnet.avi_pubnet.name
    Lab_Noshut                    = "jumpbox"
    Lab_Timezone                  = var.lab_timezone
  }
}

resource "azurerm_virtual_machine_extension" "jumpbox" {
  name                 = "${var.id}_jumpbox"
  location             = var.location
  resource_group_name  = azurerm_resource_group.avi_resource_group.name
  virtual_machine_name = azurerm_virtual_machine.jumpbox.name
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
    {
        "commandToExecute": "mkdir /root/.ssh & cp /home/aviadmin/.ssh/authorized_keys /root/.ssh/authorized_keys"
    }
SETTINGS

  tags = {
    Owner = var.owner
  }
}

resource "null_resource" "jumpbox_provisioner" {
  connection {
    host        = data.azurerm_public_ip.jumpbox_eip.ip_address
    type        = "ssh"
    agent       = false
    user        = "root"
    private_key = tls_private_key.generated_access_key.private_key_pem
  }

  provisioner "local-exec" {
    command = "chmod 0600 aviadmin.pem"
  }

  provisioner "file" {
    source      = "provisioning/bootstrap"
    destination = "/opt/bootstrap"
  }

  provisioner "file" {
    source      = "provisioning/handle_bootstrap.py"
    destination = "/usr/local/bin/handle_bootstrap.py"
  }

  provisioner "file" {
    source      = "provisioning/handle_bootstrap.service"
    destination = "/etc/systemd/system/handle_bootstrap.service"
  }

  provisioner "file" {
    source      = "provisioning/handle_register.py"
    destination = "/usr/local/bin/handle_register.py"
  }

  provisioner "file" {
    source      = "provisioning/handle_register.service"
    destination = "/etc/systemd/system/handle_register.service"
  }

  provisioner "remote-exec" {
    inline = [
      "yum install -y ansible",
  ]
  }

  provisioner "file" {
    source      = "provisioning/ansible_inventory.py"
    destination = "/etc/ansible/hosts"
  }

  provisioner "file" {
    source      = "provisioning/cleanup_controllers.py"
    destination = "/usr/local/bin/cleanup_controllers.py"
  }

  provisioner "file" {
    source      = "provisioning/provision_vm.sh"
    destination = "/tmp/provision_vm.sh"
  }

  provisioner "file" {
    source      = "provisioning/register.py"
    destination = "/usr/local/bin/register.py"
  }

  provisioner "file" {
    source      = "aviadmin.pem"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    scripts = [
      "provisioning/provision_vm.sh",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "provisioning/provision_jumpbox.sh",
    ]
  }
  depends_on        = [ local_file.aviadmin_pem, azurerm_virtual_machine.jumpbox, azurerm_virtual_machine_extension.jumpbox ]

}
