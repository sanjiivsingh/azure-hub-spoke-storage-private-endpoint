resource "azurerm_private_dns_zone" "this" {
  name                = var.dns_zone_config.name
  resource_group_name = var.dns_zone_config.resource_group_name
}