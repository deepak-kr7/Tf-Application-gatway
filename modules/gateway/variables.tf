variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "appgw_subnet_id" {
  type        = string
  description = "Subnet ID for the Application Gateway"
}

variable "appgw_name" {
  type        = string
  description = "Name of the Application Gateway"
  default     = "dev-appgw"
}

variable "capacity" {
  type        = number
  description = "Capacity (instance count) of the Application Gateway"
  default     = 2
}

variable "netflix_backend_ips" {
  type        = list(string)
  description = "List of private IPs for the Netflix VMs"
}

variable "starbucks_backend_ips" {
  type        = list(string)
  description = "List of private IPs for the Starbucks VMs"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
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
