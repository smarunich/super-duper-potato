data "azurerm_subscription" "primary" {}

provider "azurerm" {
  #tested versions
  #version = "=1.29.0"
  #version = "=1.31.0"
  subscription_id = var.azure_subscription_id
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
  tenant_id = var.azure_tenant_id
}
