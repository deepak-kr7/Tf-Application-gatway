variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "nic_id" {
  type        = string
  description = "Network Interface ID to attach to the VM"
}

variable "vm_name" {
  type        = string
  description = "Name of the VM"
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine"
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM"
  sensitive   = true
}

variable "app_name" {
  type        = string
  description = "Name of the application (e.g., Netflix, Starbucks)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
