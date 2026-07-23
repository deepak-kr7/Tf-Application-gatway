variable "resource_group_name" { type = any }
variable "location" { type = any }
variable "lb_name" { type = any }
variable "subnet_id" {
  type    = any
  default = ""
}
variable "subnet_name" {
  type    = any
  default = ""
}
variable "vnet_name" {
  type    = any
  default = ""
}
variable "backend_nic_map" {
  type    = any
  default = {}
}
variable "backend_nic_names" {
  type    = any
  default = []
}
variable "frontend_port" {
  type    = any
  default = 80
}
variable "backend_port" {
  type    = any
  default = 80
}
variable "tags" {
  type    = any
  default = {}
}
