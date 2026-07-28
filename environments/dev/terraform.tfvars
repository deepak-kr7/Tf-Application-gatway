environment    = "dev"
admin_username = "admin123"
# Sensitive passwords (admin_password, ssl_certificate_password, ssl_certificate_pfx_base64) 
# are supplied securely via Azure Key Vault / Pipeline variables to keep code DevSecOps report flag free.
tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "AppGatewayDemo"
}

# 1. Resource Groups
resource_groups = {
  main = {
    name     = "rg-dev-infra"
    location = "East US"
  }

}

# 2. Virtual Networks
vnets = {
  main = {
    name                = "vnet-dev"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_address_space  = ["10.0.0.0/16"]
  }
}

# 3. Subnets
subnets = {
  netflix = {
    name                = "sb-netflix"
    resource_group_name = "rg-dev-infra"
    vnet_name           = "vnet-dev"
    address_prefixes    = ["10.0.1.0/24"]
  }
  starbucks = {
    name                = "sb-starbucks"
    resource_group_name = "rg-dev-infra"
    vnet_name           = "vnet-dev"
    address_prefixes    = ["10.0.2.0/24"]
  }
  bastion = {
    name                = "AzureBastionSubnet"
    resource_group_name = "rg-dev-infra"
    vnet_name           = "vnet-dev"
    address_prefixes    = ["10.0.3.0/26"]
  }
  appgw = {
    name                = "sb-appgw"
    resource_group_name = "rg-dev-infra"
    vnet_name           = "vnet-dev"
    address_prefixes    = ["10.0.4.0/24"]
  }
}

# 4. Virtual Machines & NICs
virtual_machines = {
  netflix_1 = {
    name                = "netflix-vm-1"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_name         = "sb-netflix"
    nic_name            = "netflix-vm-1-nic"
    app_name            = "Netflix App"
  }
  netflix_2 = {
    name                = "netflix-vm-2"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_name         = "sb-netflix"
    nic_name            = "netflix-vm-2-nic"
    app_name            = "Netflix App"
  }
  starbucks_1 = {
    name                = "starbucks-vm-1"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_name         = "sb-starbucks"
    nic_name            = "starbucks-vm-1-nic"
    app_name            = "Starbucks App"
  }
  starbucks_2 = {
    name                = "starbucks-vm-2"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_name         = "sb-starbucks"
    nic_name            = "starbucks-vm-2-nic"
    app_name            = "Starbucks App"
  }
}

# 5. Network Security Groups
nsgs = {
  netflix = {
    nsg_name            = "nsg-netflix"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_name         = "sb-netflix"
    associate_subnet    = true
    security_rules = [
      {
        name                       = "Allow-HTTP-From-AppGW"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.0.4.0/24"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-LB-Probe"
        priority                   = 105
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "AzureLoadBalancer"
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
        source_address_prefix      = "10.0.3.0/26"
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
    nsg_name            = "nsg-starbucks"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_name         = "sb-starbucks"
    associate_subnet    = true
    security_rules = [
      {
        name                       = "Allow-HTTP-From-AppGW"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.0.4.0/24"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-LB-Probe"
        priority                   = 105
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "AzureLoadBalancer"
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
        source_address_prefix      = "10.0.3.0/26"
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

# 6. Bastion Host
bastions = {
  main = {
    name                = "bastion-dev"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_name         = "AzureBastionSubnet"
  }
}

# 7. Application Gateway
gateways = {
  main = {
    name                = "appgw-dev"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    appgw_subnet_name   = "sb-appgw"
    apps = {
      netflix = {
        host_name         = "netflixdeep.b18g2.online"
        priority          = 10
        backend_nic_names = ["netflix-vm-1-nic", "netflix-vm-2-nic"]
      }
      starbucks = {
        host_name         = "starbuckdeep.b18g2.online"
        priority          = 20
        backend_nic_names = ["starbucks-vm-1-nic", "starbucks-vm-2-nic"]
      }
    }
  }
}

# SSL certificate credentials are provided via Key Vault / Pipeline variables


# 9. AKS Clusters
aks_clusters = {
  main = {
    cluster_name                      = "aks-dev-cluster"
    dns_prefix                        = "aksdevcluster"
    resource_group_name               = "rg-dev-infra"
    location                          = "East US"
    default_node_pool_name            = "agentpool"
    default_node_pool_node_count      = 1
    default_node_pool_vm_size         = "Standard_D2s_v3"
    default_node_pool_os_disk_size_gb = 30
    default_node_pool_type            = "VirtualMachineScaleSets"
    identity_type                     = "SystemAssigned"
  }
}

# 10. Container Registries
container_registries = {
  main = {
    acr_name            = "acrdevregistryappgw"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    sku                 = "Basic"
    admin_enabled       = true
  }
}

# 11. Storage Accounts
storage_accounts = {
  main = {
    storage_account_name     = "sadevstoreappgw64537"
    resource_group_name      = "rg-dev-infra"
    location                 = "East US"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

# 12. Storage Containers
storage_containers = {
  data = {
    container_name        = "appdata"
    storage_account_name  = "sadevstoreappgw64537"
    resource_group_name   = "rg-dev-infra"
    container_access_type = "private"
  }
}

# 13. NAT Gateways
nat_gateways = {
  main = {
    nat_gateway_name    = "nat-gw-dev"
    public_ip_name      = "pip-nat-gw-dev"
    resource_group_name = "rg-dev-infra"
    location            = "East US"
    vnet_name           = "vnet-dev"
    subnet_names        = ["sb-netflix", "sb-starbucks"]
  }
}

# 14. Key Vault Details
key_vault_details = {
  name_prefix         = "kv-dev-vm"
  location            = "East US"
  resource_group_name = "rg-dev-infra"
  tenant_id           = "e9260173-8b41-459c-8cca-cc8424530cf0"
  object_id           = "2e9e3b02-e13b-4632-b1bf-b4b36b536925"
}

