resource "azurerm_network_interface" "this" {
  name                = var.virtual_machine_config.nic_name
  location            = var.virtual_machine_config.location
  resource_group_name = var.virtual_machine_config.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.virtual_machine_config.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.virtual_machine_config.public_ip_enabled ? azurerm_public_ip.this[0].id : null
  }
}