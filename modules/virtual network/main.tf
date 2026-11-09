resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_config.name
  resource_group_name = var.virtual_network_config.resource_group_name
  location            = var.virtual_network_config.location
  address_space       = var.virtual_network_config.address_space
}
