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

variable "apps" {
  type = map(object({
    host_name   = string
    priority    = number
    backend_ips = list(string)
  }))
  description = "Application routing configuration with hostname, priority and backend IPs"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
