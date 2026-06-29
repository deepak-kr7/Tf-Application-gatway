variable "environment" {
  type        = string
  description = "Environment name"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Virtual Machines"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the Virtual Machines"
  sensitive   = true
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
}

# Variable for Resource Groups map
variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  description = "Map of resource groups to create"
}

# Variable for Subnets map
variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "Map of subnets to create"
}

# Variable for Virtual Machines map
variable "virtual_machines" {
  type = map(object({
    name     = string
    subnet   = string
    app_name = string
  }))
  description = "Map of virtual machines to create"
}

# Variable for NSGs map with their security rules
variable "nsgs" {
  type = map(object({
    nsg_name         = string
    subnet_key       = string
    associate_subnet = bool
    security_rules = list(object({
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
  }))
  description = "Map of NSGs to create with their security rules"
}

variable "netflix_host_name" {
  type        = string
  description = "Host name for the Netflix site"
  default     = "netflix.b18g2.online"
}

variable "starbucks_host_name" {
  type        = string
  description = "Host name for the Starbucks site"
  default     = "starbucks.b18g2.online"
}
