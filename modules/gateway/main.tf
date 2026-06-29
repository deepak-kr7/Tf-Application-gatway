resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.appgw_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

locals {
  frontend_ip_configuration_name = "${var.appgw_name}-feip"
  
  frontend_port_name          = "${var.appgw_name}-port-80"
  
  netflix_backend_pool_name   = "${var.appgw_name}-netflix-beap"
  starbucks_backend_pool_name = "${var.appgw_name}-starbucks-beap"
  
  netflix_http_setting_name   = "${var.appgw_name}-netflix-be-htst"
  starbucks_http_setting_name = "${var.appgw_name}-starbucks-be-htst"
  
  netflix_listener_name       = "${var.appgw_name}-netflix-lstn"
  starbucks_listener_name     = "${var.appgw_name}-starbucks-lstn"
  
  netflix_routing_rule_name   = "${var.appgw_name}-netflix-rtr"
  starbucks_routing_rule_name = "${var.appgw_name}-starbucks-rtr"
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
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  # Netflix Backend Pool
  backend_address_pool {
    name         = local.netflix_backend_pool_name
    ip_addresses = var.netflix_backend_ips
  }

  # Starbucks Backend Pool
  backend_address_pool {
    name         = local.starbucks_backend_pool_name
    ip_addresses = var.starbucks_backend_ips
  }

  # HTTP Settings for Netflix (port 80 on VMs)
  backend_http_settings {
    name                  = local.netflix_http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  # HTTP Settings for Starbucks (port 80 on VMs)
  backend_http_settings {
    name                  = local.starbucks_http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  # Listener for Netflix (port 80)
  http_listener {
    name                           = local.netflix_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = var.netflix_host_name
  }

  # Listener for Starbucks (port 80)
  http_listener {
    name                           = local.starbucks_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = var.starbucks_host_name
  }

  # Routing Rule for Netflix
  request_routing_rule {
    name                       = local.netflix_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.netflix_listener_name
    backend_address_pool_name  = local.netflix_backend_pool_name
    backend_http_settings_name = local.netflix_http_setting_name
    priority                   = 10
  }

  # Routing Rule for Starbucks
  request_routing_rule {
    name                       = local.starbucks_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.starbucks_listener_name
    backend_address_pool_name  = local.starbucks_backend_pool_name
    backend_http_settings_name = local.starbucks_http_setting_name
    priority                   = 20
  }

  tags = var.tags
}
