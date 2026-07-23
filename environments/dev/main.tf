# 1. Resource Group Module
module "resource_group" {
  source          = "../../modules/azurerm_resource_group"
  resource_groups = var.resource_groups
  tags            = var.tags
}

# 2. Virtual Network Module
module "vnet" {
  source = "../../modules/azurerm_virtual_network"
  vnets  = var.vnets
  tags   = var.tags

  depends_on = [module.resource_group]
}

# 3. Subnets Module
module "subnet" {
  source  = "../../modules/azurerm_subnet"
  subnets = var.subnets

  depends_on = [module.vnet]
}

# 4. Network Security Groups Module
module "nsg" {
  source = "../../modules/azurerm_network_security_group"
  nsgs   = var.nsgs
  tags   = var.tags

  depends_on = [module.subnet]
}

# 5. Network Interfaces Module
module "nic" {
  source           = "../../modules/azurerm_network_interface"
  virtual_machines = var.virtual_machines
  tags             = var.tags

  depends_on = [module.subnet]
}

# 6. Virtual Machines Module
module "vm" {
  source           = "../../modules/azurerm_linux_virtual_machine"
  virtual_machines = var.virtual_machines
  admin_username   = var.admin_username
  admin_password   = var.admin_password
  tags             = var.tags

  depends_on = [module.nic]
}

# 7. Bastion Host Module
module "bastion" {
  source   = "../../modules/azurerm_bastion_host"
  bastions = var.bastions
  tags     = var.tags

  depends_on = [module.subnet]
}

# 8. Web Application Firewall (WAF) Policy Module
module "waf_policy" {
  source       = "../../modules/azurerm_web_application_firewall_policy"
  waf_policies = var.waf_policies
  tags         = var.tags
}

# 9. Application Gateway Module
module "gateway" {
  source                     = "../../modules/azurerm_application_gateway"
  gateways                   = var.gateways
  virtual_machines           = var.virtual_machines
  ssl_certificate_pfx_base64 = var.ssl_certificate_pfx_base64
  ssl_certificate_password   = var.ssl_certificate_password
  tags                       = var.tags

  depends_on = [module.vm, module.subnet, module.waf_policy]
}

# 10. AKS Clusters Module
module "aks" {
  source       = "../../modules/azurerm_kubernetes_cluster"
  aks_clusters = var.aks_clusters
  tags         = var.tags

  depends_on = [module.resource_group]
}

# 11. Container Registries Module
module "acr" {
  source               = "../../modules/azurerm_container_registry"
  container_registries = var.container_registries
  tags                 = var.tags

  depends_on = [module.resource_group]
}

# 12. Storage Accounts Module
module "storage_account" {
  source           = "../../modules/azurerm_storage_account"
  storage_accounts = var.storage_accounts
  tags             = var.tags

  depends_on = [module.resource_group]
}

# 13. Storage Containers Module
module "storage_container" {
  source             = "../../modules/azurerm_storage_container"
  storage_containers = var.storage_containers

  depends_on = [module.storage_account]
}

# 14. NAT Gateway Module
module "nat_gateway" {
  source       = "../../modules/azurerm_nat_gateway"
  nat_gateways = var.nat_gateways
  subnets      = var.subnets
  tags         = var.tags

  depends_on = [module.subnet]
}
