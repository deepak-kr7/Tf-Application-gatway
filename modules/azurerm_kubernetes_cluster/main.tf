resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = var.aks_clusters
  name                = each.value.cluster_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix

  default_node_pool {
    name            = each.value.default_node_pool_name
    node_count      = each.value.default_node_pool_node_count
    vm_size         = each.value.default_node_pool_vm_size
    os_disk_size_gb = each.value.default_node_pool_os_disk_size_gb
    type            = each.value.default_node_pool_type
  }

  identity {
    type = each.value.identity_type
  }

  tags = var.tags
}
