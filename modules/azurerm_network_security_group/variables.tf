variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "nsg_name" {
  type        = string
  description = "Name of the Network Security Group"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to associate with the NSG (optional)"
  default     = ""
}

variable "associate_subnet" {
  type        = bool
  description = "Whether to associate the NSG with the subnet"
  default     = false
}

variable "security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "List of security rules to create in the NSG"
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
