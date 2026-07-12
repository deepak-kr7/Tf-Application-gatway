variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "nic_id" {
  type        = string
  description = "Network Interface ID to attach to the VM"
}

variable "vm_name" {
  type        = string
  description = "Name of the VM"
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine"
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM"
  sensitive   = true
}

variable "app_name" {
  type        = string
  description = "Name of the application (e.g., Netflix, Starbucks)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}

variable "disable_password_authentication" {
  type        = bool
  description = "Specifies whether password authentication should be disabled"
  default     = false
}

variable "os_disk_caching" {
  type        = string
  description = "The caching type for OS Disk"
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "The storage account type for OS Disk"
  default     = "Standard_LRS"
}

variable "image_publisher" {
  type        = string
  description = "Publisher of the VM image"
  default     = "Canonical"
}

variable "image_offer" {
  type        = string
  description = "Offer of the VM image"
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type        = string
  description = "SKU of the VM image"
  default     = "22_04-lts"
}

variable "image_version" {
  type        = string
  description = "Version of the VM image"
  default     = "latest"
}

variable "custom_data_script" {
  type        = string
  description = "Custom data script to run on VM initialization. If empty, a default Nginx script is used."
  default     = ""
}

