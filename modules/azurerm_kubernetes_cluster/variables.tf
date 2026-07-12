variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the AKS cluster"
}

variable "default_node_pool_name" {
  type        = string
  description = "Name of the default node pool"
  default     = "default"
}

variable "default_node_pool_node_count" {
  type        = number
  description = "Number of nodes in the default node pool"
  default     = 1
}

variable "default_node_pool_vm_size" {
  type        = string
  description = "VM size for the nodes"
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_os_disk_size_gb" {
  type        = number
  description = "OS disk size in GB for the nodes"
  default     = 30
}

variable "default_node_pool_type" {
  type        = string
  description = "Type of the default node pool"
  default     = "VirtualMachineScaleSets"
}

variable "identity_type" {
  type        = string
  description = "Type of identity for the AKS cluster"
  default     = "SystemAssigned"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the AKS cluster"
  default     = {}
}
