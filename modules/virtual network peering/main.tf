resource "azurerm_virtual_network_peering" "this" {
    name                      = var.vnet_peering_config.name
    resource_group_name       = var.vnet_peering_config.resource_group_name
    virtual_network_name      = var.vnet_peering_config.virtual_network_name
    remote_virtual_network_id = var.vnet_peering_config.remote_virtual_network_id
}