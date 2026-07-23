resource "azurerm_web_application_firewall_policy" "waf" {
  for_each            = var.waf_policies
  name                = each.value.policy_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  policy_settings {
    enabled = true
    mode    = "Prevention"
  }

  tags = var.tags
}
