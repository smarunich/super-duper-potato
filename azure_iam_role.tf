# has to be improved does not provide enough access for cloud to operate
# https://github.com/avinetworks/devops/tree/master/azure/roles
resource "azurerm_role_definition" "avi_role" {
  name        = "${var.id}_role"
  scope       = data.azurerm_subscription.primary.id
  description = "This is a custom role created via Terraform"

  permissions {
    actions     =  [ "Microsoft.Network/virtualNetworks/read",
    "Microsoft.Network/virtualNetworks/checkIpAddressAvailability/read",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
    "Microsoft.Network/virtualNetworks/subnets/read",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/virtualMachines/read",
    "Microsoft.Network/virtualNetworks/virtualMachines/read",
    "Microsoft.Network/networkInterfaces/join/action",
    "Microsoft.Network/networkInterfaces/read",
    "Microsoft.Network/networkInterfaces/ipconfigurations/read",
    "Microsoft.Network/dnsZones/read",
    "Microsoft.Network/dnsZones/A/*",
    "Microsoft.Network/dnsZones/CNAME/*",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/instanceView/read",
    "Microsoft.Compute/virtualMachineScaleSets/read",
    "microsoft.Compute/virtualMachineScaleSets/*/read",
    "Microsoft.Resources/resources/read",
    "Microsoft.Resources/subscriptions/resourcegroups/read",
    "Microsoft.Resources/subscriptions/resourcegroups/resources/read"
  ]
    not_actions = []
  }
  assignable_scopes = [ data.azurerm_subscription.primary.id ,
    ]
}

resource "azurerm_role_assignment" "avi_role_assignment" {
  count = var.student_count
  scope              = azurerm_resource_group.avi_resource_group.id
  #role_definition_id = azurerm_role_definition.avi_role.id
  role_definition_name = "Contributor"
  principal_id       = lookup(azurerm_virtual_machine.ctrl[count.index].identity[0], "principal_id")
}

resource "azurerm_role_assignment" "jumpbox_role_assignment" {
  scope              = azurerm_resource_group.avi_resource_group.id
  #role_definition_id = azurerm_role_definition.avi_role.id
  role_definition_name = "Contributor"
  principal_id       = lookup(azurerm_virtual_machine.jumpbox.identity[0], "principal_id")
}