resource "azurerm_public_ip" "this" {
  count               = var.virtual_machine_config.public_ip_enabled ? 1 : 0
  name                = "${var.virtual_machine_config.vm_name}-public-ip"
  location            = var.virtual_machine_config.location
  resource_group_name = var.virtual_machine_config.resource_group_name
  allocation_method   = "Static"
}
