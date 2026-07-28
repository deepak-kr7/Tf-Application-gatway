output "key_vault_id" {
  value       = azurerm_key_vault.kv.id
  description = "The ID of the Key Vault"
}

output "key_vault_name" {
  value       = azurerm_key_vault.kv.name
  description = "The Name of the Key Vault"
}

output "secrets" {
  value       = azurerm_key_vault_secret.secrets
  sensitive   = true
  description = "Map of created Key Vault secret objects"
}
