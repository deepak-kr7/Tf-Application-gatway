variable "environment" { type = any }
variable "admin_username" { type = any }
variable "admin_password" { type = any }
variable "tags" { type = any }
variable "ssl_certificate_pfx_base64" { type = any }
variable "ssl_certificate_password" { type = any }
variable "resource_groups" { type = any }
variable "vnets" { type = any }
variable "subnets" { type = any }
variable "virtual_machines" { type = any }
variable "nsgs" { type = any }
variable "bastions" { type = any }
variable "waf_policies" {
  type    = any
  default = {}
}
variable "gateways" { type = any }
variable "aks_clusters" { type = any }
variable "container_registries" { type = any }
variable "storage_accounts" { type = any }
variable "storage_containers" { type = any }
variable "nat_gateways" { type = any }
