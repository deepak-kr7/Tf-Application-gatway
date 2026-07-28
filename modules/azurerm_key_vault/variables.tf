variable "key_vault_name" {
  type        = string
  description = "Name of the Key Vault"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "object_id" {
  type        = string
  description = "Object ID for Key Vault Access Policy"
}

variable "secrets" {
  type        = map(string)
  description = "Map of secret names and secret values to store in Key Vault"
  default     = {}
}

variable "tags" {
  type        = any
  description = "Resource tags"
  default     = {}
}
