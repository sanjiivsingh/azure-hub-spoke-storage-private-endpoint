resource "azurerm_linux_virtual_machine" "this" {
  count                           = lower(var.virtual_machine_config.vm_os) == "linux" ? 1 : 0
  name                            = var.virtual_machine_config.vm_name
  resource_group_name             = var.virtual_machine_config.resource_group_name
  location                        = var.virtual_machine_config.location
  size                            = var.virtual_machine_config.vm_size
  admin_username                  = var.virtual_machine_config.admin_username
  admin_password                  = var.virtual_machine_config.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.this.id,
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
}
