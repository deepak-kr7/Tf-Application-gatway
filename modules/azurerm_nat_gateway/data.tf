# Data source to fetch Subnets for NAT Gateway association
data "azurerm_subnet" "nat_subnets" {
  for_each             = var.subnets
  name                 = each.value.name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}
