# Resource Group Module (Creates the primary resource group for our infrastructure)
module "resource_group" {
  for_each            = var.resource_groups
  source              = "../../modules/azurerm_resource_group"
  resource_group_name = each.value.name
  location            = each.value.location
  tags                = var.tags
}

# VNet Module (Creates the virtual network, depends on the Resource Group)
module "vnet" {
  source              = "../../modules/azurerm_virtual_network"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  vnet_name           = "vnet-${var.environment}"
  vnet_address_space  = var.vnet_address_space
  tags                = var.tags

  # Depends on Resource Group creation
  depends_on = [module.resource_group]
}

# Subnets Module (Creates subnets inside the VNet, depends on the VNet)
module "subnet" {
  for_each            = var.subnets
  source              = "../../modules/azurerm_subnet"
  resource_group_name = module.resource_group["main"].resource_group_name
  vnet_name           = module.vnet.vnet_name
  subnet_name         = each.value.name
  address_prefixes    = each.value.address_prefixes

  # Depends on Virtual Network creation
  depends_on = [module.vnet]
}

# Network Security Groups (Creates NSGs and associates them with subnets, depends on the subnets)
module "nsg" {
  for_each            = var.nsgs
  source              = "../../modules/azurerm_network_security_group"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  nsg_name            = each.value.nsg_name
  subnet_id           = module.subnet[each.value.subnet_key].subnet_id
  associate_subnet    = each.value.associate_subnet
  security_rules      = each.value.security_rules
  tags                = var.tags

  # Depends on Subnets creation
  depends_on = [module.subnet]
}

# Network Interfaces (Creates NICs for VMs, depends on subnets)
module "nic" {
  for_each            = var.virtual_machines
  source              = "../../modules/azurerm_network_interface"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  subnet_id           = module.subnet[each.value.subnet].subnet_id
  nic_name            = "${each.value.name}-nic"
  tags                = var.tags

  # Depends on Subnets creation
  depends_on = [module.subnet]
}

# Virtual Machines (Creates the VMs and links them to NICs, depends on NICs)
module "vm" {
  for_each            = var.virtual_machines
  source              = "../../modules/azurerm_linux_virtual_machine"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  nic_id              = module.nic[each.key].nic_id
  vm_name             = each.value.name
  app_name            = each.value.app_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = var.tags

  # Depends on Network Interface creation
  depends_on = [module.nic]
}

# Bastion Host (Creates Bastion for secure VM access, depends on bastion subnet)
module "bastion" {
  source              = "../../modules/azurerm_bastion_host"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  bastion_subnet_id   = module.subnet["bastion"].subnet_id
  bastion_host_name   = "bastion-${var.environment}"
  tags                = var.tags

  # Depends on Subnets creation
  depends_on = [module.subnet]
}

# Application Gateway (Configures the Load Balancer, depends on VMs and appgw subnet)
module "gateway" {
  source              = "../../modules/azurerm_application_gateway"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  appgw_subnet_id     = module.subnet["appgw"].subnet_id
  appgw_name          = "appgw-${var.environment}"
  tags                = var.tags

  # SSL certificate settings
  ssl_certificate_pfx_base64 = var.ssl_certificate_pfx_base64
  ssl_certificate_password   = var.ssl_certificate_password

  # Map the gateway_apps configuration dynamically, resolving backend IPs per subnet
  apps = {
    for k, v in var.gateway_apps : k => {
      host_name   = v.host_name
      priority    = v.priority
      backend_ips = [for vm_k, vm_v in module.nic : vm_v.private_ip if var.virtual_machines[vm_k].subnet == v.subnet]
    }
  }

  # Depends on the backend VMs and Gateway Subnet creation
  depends_on = [module.vm, module.subnet]
}

# AKS Clusters
module "aks" {
  for_each                          = var.aks_clusters
  source                            = "../../modules/azurerm_kubernetes_cluster"
  resource_group_name               = module.resource_group[each.value.resource_group_key].resource_group_name
  location                          = module.resource_group[each.value.resource_group_key].resource_group_location
  cluster_name                      = each.value.cluster_name
  dns_prefix                        = each.value.dns_prefix
  default_node_pool_name            = each.value.default_node_pool_name
  default_node_pool_node_count      = each.value.default_node_pool_node_count
  default_node_pool_vm_size         = each.value.default_node_pool_vm_size
  default_node_pool_os_disk_size_gb = each.value.default_node_pool_os_disk_size_gb
  default_node_pool_type            = each.value.default_node_pool_type
  identity_type                     = each.value.identity_type
  tags                              = var.tags

  depends_on = [module.resource_group]
}

# Container Registries
module "acr" {
  for_each            = var.container_registries
  source              = "../../modules/azurerm_container_registry"
  resource_group_name = module.resource_group[each.value.resource_group_key].resource_group_name
  location            = module.resource_group[each.value.resource_group_key].resource_group_location
  acr_name            = each.value.acr_name
  sku                 = each.value.sku
  admin_enabled       = each.value.admin_enabled
  tags                = var.tags

  depends_on = [module.resource_group]
}

# Storage Accounts
module "storage_account" {
  for_each                 = var.storage_accounts
  source                   = "../../modules/azurerm_storage_account"
  resource_group_name      = module.resource_group[each.value.resource_group_key].resource_group_name
  location                 = module.resource_group[each.value.resource_group_key].resource_group_location
  storage_account_name     = each.value.storage_account_name
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  tags                     = var.tags

  depends_on = [module.resource_group]
}

# Storage Containers
module "storage_container" {
  for_each              = var.storage_containers
  source                = "../../modules/azurerm_storage_container"
  container_name        = each.value.container_name
  storage_account_id    = module.storage_account[each.value.storage_account_key].storage_account_id
  container_access_type = each.value.container_access_type

  depends_on = [module.storage_account]
}

