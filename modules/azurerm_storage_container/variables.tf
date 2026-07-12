variable "container_name" {
  type        = string
  description = "Name of the storage container"
}

variable "storage_account_id" {
  type        = string
  description = "The ID of the storage account where container will be created"
}


variable "container_access_type" {
  type        = string
  description = "Access level (private, blob, container)"
  default     = "private"
}
