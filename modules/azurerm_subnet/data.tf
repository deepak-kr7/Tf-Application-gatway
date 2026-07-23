# Data source to fetch Virtual Network for Subnet creation
data "azurerm_virtual_network" "vnet" {
  for_each            = var.subnets
  name                = each.value.vnet_name
  resource_group_name = each.value.resource_group_name
}
