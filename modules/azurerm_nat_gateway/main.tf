resource "azurerm_public_ip" "nat_pip" {
  for_each            = var.nat_gateways
  name                = each.value.public_ip_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "nat_gw" {
  for_each                = var.nat_gateways
  name                    = each.value.nat_gateway_name
  location                = each.value.location
  resource_group_name     = each.value.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  for_each             = var.nat_gateways
  nat_gateway_id       = azurerm_nat_gateway.nat_gw[each.key].id
  public_ip_address_id = azurerm_public_ip.nat_pip[each.key].id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_assoc" {
  for_each       = { for k, v in var.subnets : k => v if k == "netflix" || k == "starbucks" }
  subnet_id      = data.azurerm_subnet.nat_subnets[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gw["main"].id
}
