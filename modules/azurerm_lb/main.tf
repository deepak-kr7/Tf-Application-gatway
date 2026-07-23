# Data source to fetch Subnet ID if subnet_name is provided
data "azurerm_subnet" "lb_subnet" {
  count                = var.subnet_name != "" ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

# Data source to fetch NIC IDs if backend_nic_names is provided
data "azurerm_network_interface" "backend_nics" {
  for_each            = toset(var.backend_nic_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "private-frontend"
    subnet_id                     = var.subnet_name != "" ? data.azurerm_subnet.lb_subnet[0].id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "${var.lb_name}-beap"
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "http-health-probe"
  port                = var.backend_port
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "private-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_association" {
  for_each                = length(var.backend_nic_names) > 0 ? data.azurerm_network_interface.backend_nics : var.backend_nic_map
  network_interface_id    = length(var.backend_nic_names) > 0 ? each.value.id : each.value
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}
