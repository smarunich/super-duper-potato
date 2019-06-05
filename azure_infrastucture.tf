resource "azurerm_resource_group" "avi_resource_group" {
  name     = "${var.id}_resource_group"
  location = var.location
  tags = {
    Owner = var.owner
  }
}

resource "azurerm_virtual_network" "avi_vnet" {
  name                = "${var.id}_vnet"
  location            = var.location
  address_space       = [ var.vnet_cidr ]
  resource_group_name = azurerm_resource_group.avi_resource_group.name
  tags = {
    Owner = var.owner
  }
}

resource "azurerm_subnet" "avi_pubnet" {
  name                 =  "${var.id}_infra_network"
  resource_group_name  = azurerm_resource_group.avi_resource_group.name
  virtual_network_name = azurerm_virtual_network.avi_vnet.name
  address_prefix       = cidrsubnet(var.vnet_cidr, 8, 0)
}

resource "azurerm_subnet" "avi_privnet" {
  count                = var.student_count
  name                 = "${var.id}_student${count.index + 1}_app_network"
  resource_group_name  = azurerm_resource_group.avi_resource_group.name
  virtual_network_name = azurerm_virtual_network.avi_vnet.name
  address_prefix       = cidrsubnet(var.vnet_cidr, 8, 1)
}

resource "azurerm_subnet" "avi_mgmtnet" {
  name                 =  "${var.id}_management_network"
  resource_group_name  = azurerm_resource_group.avi_resource_group.name
  virtual_network_name = azurerm_virtual_network.avi_vnet.name
  address_prefix       = cidrsubnet(var.vnet_cidr, 8, 2)
}

resource "tls_private_key" "generated_access_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_string" "ssh_admin_password" {
  length = 16
  min_special = 2
  min_upper = 3
  min_lower = 3
  min_numeric = 3
}

