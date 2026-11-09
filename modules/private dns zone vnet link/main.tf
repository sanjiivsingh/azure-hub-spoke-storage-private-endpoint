resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                 = var.dns_zone_vnet_link_config.name
  private_dns_zone_id  = var.dns_zone_vnet_link_config.private_dns_zone_id
  virtual_network_id   = var.dns_zone_vnet_link_config.virtual_network_id
  registration_enabled = var.dns_zone_vnet_link_config.registration_enabled
}
