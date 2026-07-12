output "acr_id" {
  value       = azurerm_container_registry.acr.id
  description = "The ID of the Container Registry"
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The Login Server URL of the Container Registry"
}

output "acr_admin_username" {
  value       = azurerm_container_registry.acr.admin_username
  description = "The Admin Username for the Container Registry"
}

output "acr_admin_password" {
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
  description = "The Admin Password for the Container Registry"
}
