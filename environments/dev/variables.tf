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

variable "gateway_apps" {
  type = map(object({
    host_name = string
    priority  = number
    subnet    = string
  }))
  description = "Application configurations for the Gateway routing"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to all resources"
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "AppGatewayDemo"
  }
}

variable "ssl_certificate_pfx_base64" {
  type        = string
  description = "Base64 encoded content of the .pfx SSL certificate"
  sensitive   = true
}

variable "ssl_certificate_password" {
  type        = string
  description = "Password for the .pfx SSL certificate"
  sensitive   = true
}

variable "aks_clusters" {
  type = map(object({
    cluster_name                      = string
    dns_prefix                        = string
    resource_group_key                = string
    default_node_pool_name            = optional(string, "default")
    default_node_pool_node_count      = optional(number, 1)
    default_node_pool_vm_size         = optional(string, "Standard_DS2_v2")
    default_node_pool_os_disk_size_gb = optional(number, 30)
    default_node_pool_type            = optional(string, "VirtualMachineScaleSets")
    identity_type                     = optional(string, "SystemAssigned")
  }))
  description = "Map of AKS clusters to create"
  default     = {}
}

variable "container_registries" {
  type = map(object({
    acr_name           = string
    resource_group_key = string
    sku                = optional(string, "Basic")
    admin_enabled      = optional(bool, false)
  }))
  description = "Map of Container Registries to create"
  default     = {}
}

variable "storage_accounts" {
  type = map(object({
    storage_account_name     = string
    resource_group_key       = string
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
  }))
  description = "Map of Storage Accounts to create"
  default     = {}
}

variable "storage_containers" {
  type = map(object({
    container_name        = string
    storage_account_key   = string
    container_access_type = optional(string, "private")
  }))
  description = "Map of Storage Containers to create"
  default     = {}
}



