resource "azurerm_subnet" "this" {
  name                = var.subnet_config.name
  virtual_network_name = var.subnet_config.virtual_network_name
  resource_group_name = var.subnet_config.resource_group_name
  address_prefixes    = var.subnet_config.address_prefixes
  private_endpoint_network_policies = var.subnet_config.private_endpoint_network_policies
}
