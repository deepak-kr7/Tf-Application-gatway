variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account (3-24 characters, numbers and lowercase letters only)"
}

variable "account_tier" {
  type        = string
  description = "Tier of the storage account (Standard, Premium)"
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Replication type (LRS, GRS, RAGRS, ZRS)"
  default     = "LRS"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the Storage Account"
  default     = {}
}
