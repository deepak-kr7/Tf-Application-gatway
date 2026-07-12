variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet"
}

variable "address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the subnet"
}
