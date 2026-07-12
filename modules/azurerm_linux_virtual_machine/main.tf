resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = var.disable_password_authentication

  network_interface_ids = [
    var.nic_id
  ]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  custom_data = var.custom_data_script != "" ? base64encode(var.custom_data_script) : base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              for file in /var/www/html/index.html /var/www/html/index.nginx-debian.html; do
                if [ -f "$file" ]; then
                  sed -i "s/Welcome to nginx\!/Welcome to nginx\! on ${var.vm_name}/g" "$file"
                fi
              done
              systemctl enable nginx
              systemctl start nginx
              EOF
  )

  tags = var.tags
}

