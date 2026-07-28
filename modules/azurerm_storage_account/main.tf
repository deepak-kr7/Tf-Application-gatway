resource "azurerm_storage_account" "sa" {
  for_each                        = var.storage_accounts
  name                            = each.value.storage_account_name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  account_tier                    = each.value.account_tier
  account_replication_type        = each.value.account_replication_type
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  https_traffic_only_enabled      = true
  tags                            = var.tags
}

