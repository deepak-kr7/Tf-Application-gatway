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

variable "sku_name" {
  type        = string
  description = "SKU Name of the Application Gateway"
  default     = "Standard_v2"
}

variable "sku_tier" {
  type        = string
  description = "SKU Tier of the Application Gateway"
  default     = "Standard_v2"
}

variable "pip_allocation_method" {
  type        = string
  description = "Public IP allocation method for Application Gateway"
  default     = "Static"
}

variable "pip_sku" {
  type        = string
  description = "Public IP SKU for Application Gateway"
  default     = "Standard"
}

variable "gateway_ip_config_name" {
  type        = string
  description = "IP Configuration name of the gateway"
  default     = "appgw-ip-config"
}

variable "cookie_based_affinity" {
  type        = string
  description = "Cookie-based affinity setting for backend HTTP settings"
  default     = "Disabled"
}

variable "backend_port" {
  type        = number
  description = "Backend port for the servers"
  default     = 80
}

variable "backend_protocol" {
  type        = string
  description = "Backend protocol (Http, Https)"
  default     = "Http"
}

variable "backend_request_timeout" {
  type        = number
  description = "Backend request timeout in seconds"
  default     = 60
}

variable "rule_type" {
  type        = string
  description = "Routing rule type (Basic, PathBasedRouting)"
  default     = "Basic"
}


