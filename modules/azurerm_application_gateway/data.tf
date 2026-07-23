# Data source to fetch Application Gateway Subnet ID
data "azurerm_subnet" "appgw_subnet" {
  for_each             = var.gateways
  name                 = each.value.appgw_subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

# Data source to fetch WAF Policy ID
data "azurerm_web_application_firewall_policy" "waf" {
  for_each            = var.gateways
  name                = each.value.waf_policy_name
  resource_group_name = each.value.resource_group_name
}

# Data source to fetch Backend NIC details and Private IPs
data "azurerm_network_interface" "backend_nic" {
  for_each            = var.virtual_machines
  name                = each.value.nic_name
  resource_group_name = each.value.resource_group_name
}
