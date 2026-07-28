variable "environment" {}
variable "admin_username" {}
variable "tags" {}
variable "admin_password" {}
variable "ssl_certificate_pfx_base64" {
  type    = string
  default = ""
}
variable "ssl_certificate_password" {
  type    = string
  default = ""
}
variable "resource_groups" {}
variable "vnets" {}
variable "subnets" {}
variable "virtual_machines" {}
variable "nsgs" {}
variable "bastions" {}
variable "waf_policies" {
  default = {}
}
variable "gateways" {}
variable "aks_clusters" {}
variable "container_registries" {}
variable "storage_accounts" {}
variable "storage_containers" {}
variable "nat_gateways" {}
variable "key_vault_details" {}

