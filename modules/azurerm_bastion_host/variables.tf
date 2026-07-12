variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "bastion_subnet_id" {
  type        = string
  description = "The ID of the AzureBastionSubnet"
}

variable "bastion_host_name" {
  type        = string
  description = "Name of the Bastion Host"
  default     = "dev-bastion"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}

variable "pip_allocation_method" {
  type        = string
  description = "Public IP allocation method"
  default     = "Static"
}

variable "pip_sku" {
  type        = string
  description = "Public IP SKU"
  default     = "Standard"
}

variable "ip_config_name" {
  type        = string
  description = "Name of the IP configuration"
  default     = "configuration"
}

