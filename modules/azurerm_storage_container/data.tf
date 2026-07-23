# Data source to fetch Storage Account for Container creation
data "azurerm_storage_account" "sa" {
  for_each            = var.storage_containers
  name                = each.value.storage_account_name
  resource_group_name = each.value.resource_group_name
}
