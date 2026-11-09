resource "azurerm_private_endpoint" "this" {
  name                = var.private_endpoint_config.name
  location            = var.private_endpoint_config.location
  resource_group_name = var.private_endpoint_config.resource_group_name
  subnet_id           = var.private_endpoint_config.subnet_id

  private_service_connection {
    name                           = var.private_endpoint_config.private_service_connection_name
    private_connection_resource_id = var.private_endpoint_config.private_service_connection_resource_id
    is_manual_connection           = var.private_endpoint_config.is_manual_connection
    subresource_names              = var.private_endpoint_config.private_service_connection_subresource_names
  }

  # Optional: Private DNS Zone integration
  private_dns_zone_group {
    name                 = var.private_endpoint_config.private_dns_zone_group_name
    private_dns_zone_ids = var.private_endpoint_config.private_dns_zone_ids
  }
}
