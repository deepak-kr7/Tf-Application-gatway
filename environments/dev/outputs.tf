output "resource_group_name" {
  value       = module.resource_group["main"].resource_group_name
  description = "Name of the resource group"
}

output "vnet_name" {
  value       = module.vnet.vnet_name
  description = "Name of the Virtual Network"
}

output "netflix_private_ips" {
  value       = [for k, v in module.nic : v.private_ip if var.virtual_machines[k].subnet == "netflix"]
  description = "Private IPs of the Netflix application VMs"
}

output "starbucks_private_ips" {
  value       = [for k, v in module.nic : v.private_ip if var.virtual_machines[k].subnet == "starbucks"]
  description = "Private IPs of the Starbucks application VMs"
}

output "bastion_dns_name" {
  value       = module.bastion.bastion_dns_name
  description = "FQDN of the Bastion Host"
}

output "application_gateway_public_ip" {
  value       = module.gateway.public_ip
  description = "Public IP address of the Application Gateway"
}

output "netflix_url" {
  value       = "https://${var.gateway_apps["netflix"].host_name}"
  description = "URL to access Netflix app through Application Gateway"
}

output "starbucks_url" {
  value       = "https://${var.gateway_apps["starbucks"].host_name}"
  description = "URL to access Starbucks app through Application Gateway"
}
