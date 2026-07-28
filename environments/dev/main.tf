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

# Key Vault Module
resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
}

module "key_vault" {
  source              = "../../modules/azurerm_key_vault"
  key_vault_name      = "${var.key_vault_details.name_prefix}-${random_string.kv_suffix.result}"
  location            = var.key_vault_details.location
  resource_group_name = var.key_vault_details.resource_group_name
  tenant_id           = var.key_vault_details.tenant_id
  object_id           = var.key_vault_details.object_id
  secrets = merge(
    var.admin_password != null && var.admin_password != "" ? { "vm-admin-password" = var.admin_password } : {},
    var.ssl_certificate_password != null && var.ssl_certificate_password != "" ? { "ssl-certificate-password" = var.ssl_certificate_password } : {},
    var.ssl_certificate_pfx_base64 != null && var.ssl_certificate_pfx_base64 != "" ? { "ssl-certificate-pfx-base64" = var.ssl_certificate_pfx_base64 } : {}
  )
  tags = var.tags

  depends_on = [module.resource_group]
}

# 6. Virtual Machines Module
module "vm" {
  source           = "../../modules/azurerm_linux_virtual_machine"
  virtual_machines = var.virtual_machines
  admin_username   = var.admin_username
  admin_password   = try(module.key_vault.secrets["vm-admin-password"].value, var.admin_password)
  tags             = var.tags

  depends_on = [module.nic, module.key_vault]
}

# 7. Bastion Host Module
module "bastion" {
  source   = "../../modules/azurerm_bastion_host"
  bastions = var.bastions
  tags     = var.tags

  depends_on = [module.subnet]
}

# 8. Application Gateway Module
module "gateway" {
  source                     = "../../modules/azurerm_application_gateway"
  gateways                   = var.gateways
  virtual_machines           = var.virtual_machines
  ssl_certificate_pfx_base64 = try(module.key_vault.secrets["ssl-certificate-pfx-base64"].value, var.ssl_certificate_pfx_base64)
  ssl_certificate_password   = try(module.key_vault.secrets["ssl-certificate-password"].value, var.ssl_certificate_password)
  tags                       = var.tags

  depends_on = [module.vm, module.subnet, module.key_vault]
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
