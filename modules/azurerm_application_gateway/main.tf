resource "azurerm_public_ip" "appgw_pip" {
  for_each            = var.gateways
  name                = "${each.value.name}-pip"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  for_each            = var.gateways
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = data.azurerm_subnet.appgw_subnet[each.key].id
  }

  frontend_port {
    name = "${each.value.name}-port-80"
    port = 80
  }

  frontend_port {
    name = "${each.value.name}-port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${each.value.name}-feip"
    public_ip_address_id = azurerm_public_ip.appgw_pip[each.key].id
  }

  ssl_certificate {
    name     = "${each.value.name}-cert"
    data     = var.ssl_certificate_pfx_base64
    password = var.ssl_certificate_password
  }

  dynamic "backend_address_pool" {
    for_each = each.value.apps
    content {
      name = "${each.value.name}-${backend_address_pool.key}-beap"
      ip_addresses = [
        for vm_k, vm_v in var.virtual_machines :
        data.azurerm_network_interface.backend_nic[vm_k].private_ip_address
        if contains(backend_address_pool.value.backend_nic_names, vm_v.nic_name)
      ]
    }
  }

  dynamic "backend_http_settings" {
    for_each = each.value.apps
    content {
      name                  = "${each.value.name}-${backend_http_settings.key}-be-htst"
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 60
    }
  }

  dynamic "http_listener" {
    for_each = each.value.apps
    content {
      name                           = "${each.value.name}-${http_listener.key}-http-lstn"
      frontend_ip_configuration_name = "${each.value.name}-feip"
      frontend_port_name             = "${each.value.name}-port-80"
      protocol                       = "Http"
      host_name                      = http_listener.value.host_name
    }
  }

  dynamic "http_listener" {
    for_each = each.value.apps
    content {
      name                           = "${each.value.name}-${http_listener.key}-https-lstn"
      frontend_ip_configuration_name = "${each.value.name}-feip"
      frontend_port_name             = "${each.value.name}-port-443"
      protocol                       = "Https"
      ssl_certificate_name           = "${each.value.name}-cert"
      host_name                      = http_listener.value.host_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = each.value.apps
    content {
      name                       = "${each.value.name}-${request_routing_rule.key}-http-rtr"
      rule_type                  = "Basic"
      http_listener_name         = "${each.value.name}-${request_routing_rule.key}-http-lstn"
      backend_address_pool_name  = "${each.value.name}-${request_routing_rule.key}-beap"
      backend_http_settings_name = "${each.value.name}-${request_routing_rule.key}-be-htst"
      priority                   = request_routing_rule.value.priority
    }
  }

  dynamic "request_routing_rule" {
    for_each = each.value.apps
    content {
      name                       = "${each.value.name}-${request_routing_rule.key}-https-rtr"
      rule_type                  = "Basic"
      http_listener_name         = "${each.value.name}-${request_routing_rule.key}-https-lstn"
      backend_address_pool_name  = "${each.value.name}-${request_routing_rule.key}-beap"
      backend_http_settings_name = "${each.value.name}-${request_routing_rule.key}-be-htst"
      priority                   = request_routing_rule.value.priority + 100
    }
  }

  tags = var.tags
}
