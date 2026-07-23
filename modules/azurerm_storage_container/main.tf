resource "azurerm_storage_container" "sc" {
  for_each              = var.storage_containers
  name                  = each.value.container_name
  storage_account_id    = data.azurerm_storage_account.sa[each.key].id
  container_access_type = each.value.container_access_type
}
