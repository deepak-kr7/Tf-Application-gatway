# Data source to fetch Subnet for Bastion Host
data "azurerm_subnet" "bastion_subnet" {
  for_each             = var.bastions
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}
