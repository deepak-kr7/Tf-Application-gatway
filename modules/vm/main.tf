resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    var.nic_id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
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
