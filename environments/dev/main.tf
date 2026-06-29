locals {
  vnet_name = "vnet-${var.environment}"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "AppGatewayDemo"
  }

  # Dynamically filter private IPs for Netflix backend pool
  netflix_backend_ips = [
    for k, v in module.nic : v.private_ip if var.virtual_machines[k].subnet == "netflix"
  ]

  # Dynamically filter private IPs for Starbucks backend pool
  starbucks_backend_ips = [
    for k, v in module.nic : v.private_ip if var.virtual_machines[k].subnet == "starbucks"
  ]
}

# Resource Group Module (using for_each to support multiple RGs in the future)
module "resource_group" {
  for_each            = var.resource_groups
  source              = "../../modules/resource_group"
  resource_group_name = each.value.name
  location            = each.value.location
  tags                = local.tags
}

# VNet Module (referencing the 'main' resource group)
module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  vnet_name           = local.vnet_name
  vnet_address_space  = var.vnet_address_space
  tags                = local.tags
}

# Subnets Module (using for_each to create all 4 subnets dynamically)
module "subnet" {
  for_each            = var.subnets
  source              = "../../modules/subnet"
  resource_group_name = module.resource_group["main"].resource_group_name
  vnet_name           = module.vnet.vnet_name
  subnet_name         = each.value.name
  address_prefixes    = each.value.address_prefixes
}

# Network Security Groups (using for_each to create NSGs and associate them dynamically)
module "nsg" {
  for_each            = var.nsgs
  source              = "../../modules/nsg"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  nsg_name            = each.value.nsg_name
  subnet_id           = module.subnet[each.value.subnet_key].subnet_id
  associate_subnet    = each.value.associate_subnet
  security_rules      = each.value.security_rules
  tags                = local.tags
}

# Network Interfaces (using for_each to create a NIC for each VM)
module "nic" {
  for_each            = var.virtual_machines
  source              = "../../modules/nic"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  subnet_id           = module.subnet[each.value.subnet].subnet_id
  nic_name            = "${each.value.name}-nic"
  tags                = local.tags
}

# Virtual Machines (using for_each to create a VM for each entry)
module "vm" {
  for_each            = var.virtual_machines
  source              = "../../modules/vm"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  nic_id              = module.nic[each.key].nic_id
  vm_name             = each.value.name
  app_name            = each.value.app_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = local.tags
}

# Bastion Host (uses the subnet created dynamically with key 'bastion')
module "bastion" {
  source              = "../../modules/bastion"
  resource_group_name = module.resource_group["main"].resource_group_name
  location            = module.resource_group["main"].resource_group_location
  bastion_subnet_id   = module.subnet["bastion"].subnet_id
  bastion_host_name   = "bastion-${var.environment}"
  tags                = local.tags
}

# Application Gateway (uses the subnet created dynamically with key 'appgw')
module "gateway" {
  source                = "../../modules/gateway"
  resource_group_name   = module.resource_group["main"].resource_group_name
  location              = module.resource_group["main"].resource_group_location
  appgw_subnet_id       = module.subnet["appgw"].subnet_id
  appgw_name            = "appgw-${var.environment}"
  netflix_backend_ips   = local.netflix_backend_ips
  starbucks_backend_ips = local.starbucks_backend_ips
  netflix_host_name     = var.netflix_host_name
  starbucks_host_name   = var.starbucks_host_name
  tags                  = local.tags
}
