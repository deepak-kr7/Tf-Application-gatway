variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry"
}

variable "sku" {
  type        = string
  description = "The SKU of the container registry"
  default     = "Basic"
}

variable "admin_enabled" {
  type        = bool
  description = "Specifies whether the admin user is enabled"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags for the ACR"
  default     = {}
}
