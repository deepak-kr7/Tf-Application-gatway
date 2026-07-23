resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.virtual_machines
  name                            = each.value.name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    data.azurerm_network_interface.nic[each.key].id
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
                  sed -i "s/Welcome to nginx\!/Welcome to nginx\! on ${each.value.name}/g" "$file"
                fi
              done
              systemctl enable nginx
              systemctl start nginx
              EOF
  )

  tags = var.tags
}
