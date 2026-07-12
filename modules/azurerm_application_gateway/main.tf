resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.appgw_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.pip_allocation_method
  sku                 = var.pip_sku
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_config_name
    subnet_id = var.appgw_subnet_id
  }

  frontend_port {
    name = "${var.appgw_name}-port-80"
    port = 80
  }

  frontend_port {
    name = "${var.appgw_name}-port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${var.appgw_name}-feip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  ssl_certificate {
    name     = "${var.appgw_name}-cert"
    data     = var.ssl_certificate_pfx_base64
    password = var.ssl_certificate_password
  }

  # Dynamic backend address pools
  dynamic "backend_address_pool" {
    for_each = var.apps
    content {
      name         = "${var.appgw_name}-${backend_address_pool.key}-beap"
      ip_addresses = backend_address_pool.value.backend_ips
    }
  }

  # Dynamic HTTP settings (Port 80 on VMs)
  dynamic "backend_http_settings" {
    for_each = var.apps
    content {
      name                  = "${var.appgw_name}-${backend_http_settings.key}-be-htst"
      cookie_based_affinity = var.cookie_based_affinity
      port                  = var.backend_port
      protocol              = var.backend_protocol
      request_timeout       = var.backend_request_timeout
    }
  }

  # Dynamic HTTP listeners (Port 80)
  dynamic "http_listener" {
    for_each = var.apps
    content {
      name                           = "${var.appgw_name}-${http_listener.key}-http-lstn"
      frontend_ip_configuration_name = "${var.appgw_name}-feip"
      frontend_port_name             = "${var.appgw_name}-port-80"
      protocol                       = "Http"
      host_name                      = http_listener.value.host_name
    }
  }

  # Dynamic HTTPS listeners (Port 443 - HTTPS)
  dynamic "http_listener" {
    for_each = var.apps
    content {
      name                           = "${var.appgw_name}-${http_listener.key}-https-lstn"
      frontend_ip_configuration_name = "${var.appgw_name}-feip"
      frontend_port_name             = "${var.appgw_name}-port-443"
      protocol                       = "Https"
      ssl_certificate_name           = "${var.appgw_name}-cert"
      host_name                      = http_listener.value.host_name
    }
  }

  # Dynamic HTTP request routing rules (Port 80)
  dynamic "request_routing_rule" {
    for_each = var.apps
    content {
      name                       = "${var.appgw_name}-${request_routing_rule.key}-http-rtr"
      rule_type                  = var.rule_type
      http_listener_name         = "${var.appgw_name}-${request_routing_rule.key}-http-lstn"
      backend_address_pool_name  = "${var.appgw_name}-${request_routing_rule.key}-beap"
      backend_http_settings_name = "${var.appgw_name}-${request_routing_rule.key}-be-htst"
      priority                   = request_routing_rule.value.priority
    }
  }

  # Dynamic HTTPS request routing rules (Port 443)
  dynamic "request_routing_rule" {
    for_each = var.apps
    content {
      name                       = "${var.appgw_name}-${request_routing_rule.key}-https-rtr"
      rule_type                  = var.rule_type
      http_listener_name         = "${var.appgw_name}-${request_routing_rule.key}-https-lstn"
      backend_address_pool_name  = "${var.appgw_name}-${request_routing_rule.key}-beap"
      backend_http_settings_name = "${var.appgw_name}-${request_routing_rule.key}-be-htst"
      priority                   = request_routing_rule.value.priority + 100
    }
  }

  tags = var.tags
}
