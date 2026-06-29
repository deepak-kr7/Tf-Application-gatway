# Azure Multi-App Infrastructure (Simplified & Dynamic with for_each)

This project implements a parent-child module structure in Terraform using a **simplified, dynamic approach**. All configurations are driven entirely from `terraform.tfvars` using **nested maps** and `for_each`.

---

## 🏗️ Simplified Architecture (सरल संरचना)

Instead of hardcoding multiple module calls, the parent module uses `for_each` to loop over the maps defined in `terraform.tfvars`. 
* **Child modules (`subnet`, `nic`, `vm`, `nsg`)** are kept extremely simple: they only define a **single resource** or set of resources without internal counts or loops.
* **The parent module** manages the multiplicity (looping) using `for_each`, which is the industry best practice.

---

## 📁 File Structure (फ़ाइल संरचना)

```text
├── environments/
│   └── dev/
│       ├── main.tf             # Parent module orchestrating child modules via for_each
│       ├── variables.tf        # Input variable declarations (defines map types)
│       ├── outputs.tf          # Deployed resource outputs (URLs, IPs)
│       ├── providers.tf        # Provider settings
│       └── terraform.tfvars    # <-- ALL VALUES AND NESTED MAPS ARE DEFINED HERE
└── modules/
    ├── resource_group/         # Child module for Resource Group
    ├── vnet/                   # Child module for VNet
    ├── subnet/                 # Simple subnet module (no loops)
    ├── nsg/                    # Child module for Network Security Groups (NSG) and Rules
    ├── nic/                    # Simple NIC module (no loops)
    ├── vm/                     # Simple VM module (no loops)
    ├── bastion/                # Child module for Azure Bastion
    └── gateway/                # Child module for Application Gateway (Host-based Routing)
```

---

## ⚙️ Configuration in `terraform.tfvars`

All configurations, including resource groups, subnets, NSGs, VMs, and custom domain hostnames are defined inside [terraform.tfvars](file:///Users/deepak/Documents/Terraform/Application%20gatway/environments/dev/terraform.tfvars):

```hcl
# Resource Groups map
resource_groups = {
  main = {
    name     = "rg-dev-nfra"
    location = "East US"
  }
}

# Subnets nested map
subnets = {
  netflix   = { name = "sb-netflix", address_prefixes = ["10.0.1.0/24"] }
  starbucks = { name = "sb-starbucks", address_prefixes = ["10.0.2.0/24"] }
  bastion   = { name = "AzureBastionSubnet", address_prefixes = ["10.0.3.0/26"] }
  appgw     = { name = "sb-appgw", address_prefixes = ["10.0.4.0/24"] }
}

# Network Security Groups (NSG) and Security Rules
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
        ...
      }
    ]
  }
  starbucks = {
    nsg_name         = "nsg-starbucks"
    subnet_key       = "starbucks"
    ...
  }
}

# VMs nested map
virtual_machines = {
  netflix_1   = { name = "netflix-vm-1", subnet = "netflix", app_name = "Netflix App" }
  netflix_2   = { name = "netflix-vm-2", subnet = "netflix", app_name = "Netflix App" }
  starbucks_1 = { name = "starbucks-vm-1", subnet = "starbucks", app_name = "Starbucks App" }
  starbucks_2 = { name = "starbucks-vm-2", subnet = "starbucks", app_name = "Starbucks App" }
}

# Custom Hostnames for Application Gateway Host-Based Routing
netflix_host_name   = "netflix.b18g2.online"
starbucks_host_name = "starbucks.b18g2.online"
```

---

## 🚀 How to Deploy (कैसे चलाएं)

1. **Login to Azure**:
   ```bash
   az login
   ```
2. **Go to dev environment**:
   ```bash
   cd environments/dev
   ```
3. **Initialize & Apply**:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
4. **Test App Gateway Host-Based Routing**:
   Since the Application Gateway is configured for host-based routing on port 80, you can test it in two ways:

   * **Option A: Test via `curl` (Header Injection)**:
     ```bash
     # Get the public IP from Terraform output
     # Then run:
     curl -H "Host: netflix.b18g2.online" http://<public_ip>
     curl -H "Host: starbucks.b18g2.online" http://<public_ip>
     ```

   * **Option B: Map Hostnames in local `hosts` file**:
     Add the following entries to your local `/etc/hosts` (Mac/Linux) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
     ```text
     <public_ip> netflix.b18g2.online
     <public_ip> starbucks.b18g2.online
     ```
     Then open your browser and navigate to:
     * Netflix: [http://netflix.b18g2.online](http://netflix.b18g2.online)
     * Starbucks: [http://starbucks.b18g2.online](http://starbucks.b18g2.online)
