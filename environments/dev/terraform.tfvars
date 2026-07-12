environment        = "dev"
admin_username     = "admin123"
admin_password     = "admin@123456"
vnet_address_space = ["10.0.0.0/16"]

# Map for Resource Groups (for_each ready)
resource_groups = {
  main = {
    name     = "rg-dev-infra"
    location = "East US"
  }
}

# Nested map for Subnets
subnets = {
  netflix   = { name = "sb-netflix", address_prefixes = ["10.0.1.0/24"] }
  starbucks = { name = "sb-starbucks", address_prefixes = ["10.0.2.0/24"] }
  bastion   = { name = "AzureBastionSubnet", address_prefixes = ["10.0.3.0/26"] }
  appgw     = { name = "sb-appgw", address_prefixes = ["10.0.4.0/24"] }
}

# Nested map for Virtual Machines
virtual_machines = {
  netflix_1   = { name = "netflix-vm-1", subnet = "netflix", app_name = "Netflix App" }
  netflix_2   = { name = "netflix-vm-2", subnet = "netflix", app_name = "Netflix App" }
  starbucks_1 = { name = "starbucks-vm-1", subnet = "starbucks", app_name = "Starbucks App" }
  starbucks_2 = { name = "starbucks-vm-2", subnet = "starbucks", app_name = "Starbucks App" }
}

# Nested map for NSGs and their Security Rules
nsgs = {
  netflix = {
    nsg_name         = "nsg-netflix"
    subnet_key       = "netflix"
    associate_subnet = true
    security_rules = [
      {
        name                       = "Allow-HTTP-From-AppGW"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.0.4.0/24" # App Gateway Subnet CIDR
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-SSH-From-Bastion"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.3.0/26" # Bastion Subnet CIDR (Secure Access)
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-HTTPS"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
  starbucks = {
    nsg_name         = "nsg-starbucks"
    subnet_key       = "starbucks"
    associate_subnet = true
    security_rules = [
      {
        name                       = "Allow-HTTP-From-AppGW"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.0.4.0/24" # App Gateway Subnet CIDR
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-SSH-From-Bastion"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.3.0/26" # Bastion Subnet CIDR (Secure Access)
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-HTTPS"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

gateway_apps = {
  netflix = {
    host_name = "netflixdeep.b18g2.online"
    priority  = 10
    subnet    = "netflix"
  }
  starbucks = {
    host_name = "starbucksdeep.b18g2.online"
    priority  = 20
    subnet    = "starbucks"
  }
}

ssl_certificate_pfx_base64 = "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"
ssl_certificate_password   = "Welcome@123456"

aks_clusters = {
  main = {
    cluster_name                      = "aks-dev-cluster"
    dns_prefix                        = "aksdevcluster"
    resource_group_key                = "main"
    default_node_pool_name            = "agentpool"
    default_node_pool_node_count      = 1
    default_node_pool_vm_size         = "Standard_D2s_v3"
    default_node_pool_os_disk_size_gb = 30

    default_node_pool_type            = "VirtualMachineScaleSets"
    identity_type                     = "SystemAssigned"
  }
}

container_registries = {
  main = {
    acr_name           = "acrdevregistryappgw"
    resource_group_key = "main"
    sku                = "Basic"
    admin_enabled      = true
  }
}

storage_accounts = {
  main = {
    storage_account_name     = "sadevstoreappgw"
    resource_group_key       = "main"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

storage_containers = {
  data = {
    container_name        = "appdata"
    storage_account_key   = "main"
    container_access_type = "private"
  }
}

