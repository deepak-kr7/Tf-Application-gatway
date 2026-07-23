# Data source to fetch Subnet for NSG association
data "azurerm_subnet" "subnet" {
  for_each             = var.nsgs
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}
