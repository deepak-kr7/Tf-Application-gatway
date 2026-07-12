output "bastion_id" {
  value       = azurerm_bastion_host.bastion.id
  description = "The ID of the Bastion Host"
}

output "bastion_dns_name" {
  value       = azurerm_bastion_host.bastion.dns_name
  description = "The FQDN of the Bastion Host"
}
