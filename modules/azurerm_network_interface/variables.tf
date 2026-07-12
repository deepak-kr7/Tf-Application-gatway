variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the NIC will reside"
}

variable "nic_name" {
  type        = string
  description = "Name of the network interface"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}

variable "ip_config_name" {
  type        = string
  description = "The name of the IP configuration"
  default     = "internal"
}

variable "private_ip_address_allocation" {
  type        = string
  description = "The IP address allocation method (Dynamic, Static)"
  default     = "Dynamic"
}

