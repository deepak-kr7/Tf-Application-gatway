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

netflix_host_name   = "netflix.b18g2.online"
starbucks_host_name = "starbucks.b18g2.online"
