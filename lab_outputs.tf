# Outputs for Terraform

resource "local_file" "aviadmin_pem" {
    content     = tls_private_key.generated_access_key.private_key_pem
    filename = "${path.module}/aviadmin.pem"
    depends_on        = [ tls_private_key.generated_access_key ]
}

output "JumpHost_PublicIP" {
  value = data.azurerm_public_ip.jumpbox_eip.ip_address
}

output "Jumphost_PrivateIP" {
  value = azurerm_network_interface.jumpbox_nic.private_ip_address
}

output "Controller_PublicIP" {
  value = data.azurerm_public_ip.ctrl_eip.*.ip_address
}

output "Controller_PrivateIP" {
  value = azurerm_network_interface.ctrl_nic.*.private_ip_address
}

output "Server_PrivateIP" {
  value = azurerm_network_interface.server_nic.*.private_ip_address
}

output "Generated_Access_Key" {
  value = "Please use generated aviadmin.pem key to access Jumphost by SSH"
#  value = tls_private_key.generated_access_key.private_key_pem
}

output "Generated_SSH_Controller_Password" {
  value = random_string.ssh_admin_password.result
}
