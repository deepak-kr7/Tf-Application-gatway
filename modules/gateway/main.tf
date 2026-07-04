resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.appgw_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.appgw_subnet_id
  }

  frontend_port {
    name = "${var.appgw_name}-port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.appgw_name}-feip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  # Netflix Backend Pool
  backend_address_pool {
    name         = "${var.appgw_name}-netflix-beap"
    ip_addresses = var.netflix_backend_ips
  }

  # Starbucks Backend Pool
  backend_address_pool {
    name         = "${var.appgw_name}-starbucks-beap"
    ip_addresses = var.starbucks_backend_ips
  }

  # HTTP Settings for Netflix (port 80 on VMs)
  backend_http_settings {
    name                  = "${var.appgw_name}-netflix-be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  # HTTP Settings for Starbucks (port 80 on VMs)
  backend_http_settings {
    name                  = "${var.appgw_name}-starbucks-be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  # Listener for Netflix (port 80)
  http_listener {
    name                           = "${var.appgw_name}-netflix-lstn"
    frontend_ip_configuration_name = "${var.appgw_name}-feip"
    frontend_port_name             = "${var.appgw_name}-port-80"
    protocol                       = "Http"
    host_name                      = var.netflix_host_name
  }

  # Listener for Starbucks (port 80)
  http_listener {
    name                           = "${var.appgw_name}-starbucks-lstn"
    frontend_ip_configuration_name = "${var.appgw_name}-feip"
    frontend_port_name             = "${var.appgw_name}-port-80"
    protocol                       = "Http"
    host_name                      = var.starbucks_host_name
  }

  # Routing Rule for Netflix
  request_routing_rule {
    name                       = "${var.appgw_name}-netflix-rtr"
    rule_type                  = "Basic"
    http_listener_name         = "${var.appgw_name}-netflix-lstn"
    backend_address_pool_name  = "${var.appgw_name}-netflix-beap"
    backend_http_settings_name = "${var.appgw_name}-netflix-be-htst"
    priority                   = 10
  }

  # Routing Rule for Starbucks
  request_routing_rule {
    name                       = "${var.appgw_name}-starbucks-rtr"
    rule_type                  = "Basic"
    http_listener_name         = "${var.appgw_name}-starbucks-lstn"
    backend_address_pool_name  = "${var.appgw_name}-starbucks-beap"
    backend_http_settings_name = "${var.appgw_name}-starbucks-be-htst"
    priority                   = 20
  }

  tags = var.tags
}
