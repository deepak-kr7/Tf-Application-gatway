output "nic_id" {
  value       = azurerm_network_interface.nic.id
  description = "The ID of the Network Interface"
}

output "private_ip" {
  value       = azurerm_network_interface.nic.private_ip_address
  description = "The private IP address of the Network Interface"
}
