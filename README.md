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

## ⚙️ Configuration (कॉन्फ़िगरेशन विवरण)

All infrastructure parameters are dynamically driven and configured inside [terraform.tfvars](file:///Users/deepak/Documents/Terraform/Application%20gatway/environments/dev/terraform.tfvars). The configuration consists of the following key components:

1. **Resource Groups**: Configured via the `resource_groups` map, defining the name and location (e.g., East US) for resource deployment.
2. **Subnets**: Defined using the `subnets` map, specifying names and address prefixes for different tiers (Netflix, Starbucks, Bastion, and Application Gateway).
3. **Network Security Groups (NSGs)**: Configured using the `nsgs` map, defining custom NSGs, their subnet associations, and security rules (e.g., allowing HTTP from the Application Gateway, SSH from Bastion, and HTTPS).
4. **Virtual Machines**: Configured via the `virtual_machines` map, specifying the VM name, target subnet, and application name (e.g., Netflix App, Starbucks App).
5. **Custom Hostnames**: Declared using `netflix_host_name` and `starbucks_host_name` variables to enable host-based routing on the Application Gateway.

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
