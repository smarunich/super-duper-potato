# Terraform definition for the lab Controllers

resource "azurerm_public_ip" "ctrl_eip" {
  count         = var.student_count
  name                         = "${var.id}_student${count.index + 1}_ctrl_eip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.avi_resource_group.name
  allocation_method            = "Dynamic"
  domain_name_label            = lower("${var.id}student${count.index + 1}")
  tags = {
    Owner = var.owner
  }
}

# to recapture the data required for provisioner
data "azurerm_public_ip" "ctrl_eip" {
  count  = var.student_count
  name                         =  "${var.id}_student${count.index + 1}_ctrl_eip"
  resource_group_name          = azurerm_resource_group.avi_resource_group.name
}

resource "azurerm_network_interface" "ctrl_nic" {
  count         = var.student_count
  name                      = "${var.id}_student${count.index + 1}_ctrl_nic"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.avi_resource_group.name
  network_security_group_id = azurerm_network_security_group.ctrl_sg.id
  ip_configuration {
    name                          =  "${var.id}_student${count.index + 1}_ctrl_ip"
    subnet_id                     =  azurerm_subnet.avi_pubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ctrl_eip[count.index].id
  }
  tags = {
    Owner = var.owner
  }
}

resource "azurerm_virtual_machine" "ctrl" {
  count         = var.student_count
  name          = "${var.id}_student${count.index + 1}_controller"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.avi_resource_group.name
  vm_size                   = var.flavour_avi
  network_interface_ids     = [ azurerm_network_interface.ctrl_nic[count.index].id ]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "${var.id}_student${count.index + 1}_ctrl_ssd"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    disk_size_gb      =  var.vol_size_avi
  }

  storage_image_reference {
    id = var.azure_avi_image_id
  }

  os_profile {
    computer_name = "student${count.index + 1}"
    admin_username = var.avi_ssh_admin_username
    admin_password = random_string.ssh_admin_password.result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  # For MSI aka Azure IAM
  identity {
    type = "SystemAssigned"
  }

  depends_on        = [ null_resource.jumpbox_provisioner ]

  tags = {
    Owner = var.owner
    Lab_Group          = "controllers"
    Lab_Name           = "controller.student${count.index + 1}.lab"
    ansible_connection = "local"
    Lab_Timezone       = var.lab_timezone
  }
}

resource "azurerm_virtual_machine_extension" "ctrl" {
  count                = var.student_count
  name                 = "${var.id}_student${count.index + 1}_controller"
  location             = var.location
  resource_group_name  = azurerm_resource_group.avi_resource_group.name
  virtual_machine_name = azurerm_virtual_machine.ctrl[count.index].name
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
    {
        "commandToExecute": "cd /tmp && curl -O http://${azurerm_network_interface.jumpbox_nic.private_ip_address}/register.py && chmod a+x /tmp/register.py && /tmp/register.py ${azurerm_network_interface.jumpbox_nic.private_ip_address}"
    }
SETTINGS

  depends_on        = [ null_resource.jumpbox_provisioner ]

  tags = {
    Owner              = var.owner
  }
}
