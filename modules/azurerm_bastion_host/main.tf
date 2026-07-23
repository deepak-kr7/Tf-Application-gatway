resource "azurerm_public_ip" "bastion_pip" {
  for_each            = var.bastions
  name                = "${each.value.name}-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  for_each            = var.bastions
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.bastion_subnet[each.key].id
    public_ip_address_id = azurerm_public_ip.bastion_pip[each.key].id
  }

  tags = var.tags
}
