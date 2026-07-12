output "container_id" {
  value       = azurerm_storage_container.sc.id
  description = "The ID of the Storage Container"
}

output "container_name" {
  value       = azurerm_storage_container.sc.name
  description = "The Name of the Storage Container"
}
