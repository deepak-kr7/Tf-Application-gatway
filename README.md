# Azure Multi-App Infrastructure (Simplified & Dynamic with for_each)

This project implements a parent-child module structure in Terraform using a **simplified, dynamic approach**. All configurations are driven entirely from `terraform.tfvars` using **nested maps** and `for_each`.

---

## 🏗️ Simplified Architecture (सरल संरचना)

Instead of hardcoding multiple module calls, the parent module uses `for_each` to loop over the maps defined in `terraform.tfvars`. 
* **Child modules (`subnet`, `nic`, `vm`)** are kept extremely simple: they only define a **single resource** without internal counts or loops.
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
    ├── nic/                    # Simple NIC module (no loops)
    ├── vm/                     # Simple VM module (no loops)
    ├── bastion/                # Child module for Azure Bastion
    └── gateway/                # Child module for Application Gateway
```

---

## ⚙️ Configuration in `terraform.tfvars`

All subnets and VMs are defined inside [terraform.tfvars](file:///Users/deepak/Documents/Terraform/Application%20gatway/environments/dev/terraform.tfvars):

```hcl
# Subnets nested map
subnets = {
  netflix   = { name = "sb-netflix", address_prefixes = ["10.0.1.0/24"] }
  starbucks = { name = "sb-starbucks", address_prefixes = ["10.0.2.0/24"] }
  bastion   = { name = "AzureBastionSubnet", address_prefixes = ["10.0.3.0/26"] }
  appgw     = { name = "sb-appgw", address_prefixes = ["10.0.4.0/24"] }
}

# VMs nested map
virtual_machines = {
  netflix_1   = { name = "netflix-vm-1", subnet = "netflix", app_name = "Netflix App" }
  netflix_2   = { name = "netflix-vm-2", subnet = "netflix", app_name = "Netflix App" }
  starbucks_1 = { name = "starbucks-vm-1", subnet = "starbucks", app_name = "Starbucks App" }
  starbucks_2 = { name = "starbucks-vm-2", subnet = "starbucks", app_name = "Starbucks App" }
}
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
4. **Test App Gateway URLs**:
   * Netflix: `http://<public_ip>:8080`
   * Starbucks: `http://<public_ip>:8081`
