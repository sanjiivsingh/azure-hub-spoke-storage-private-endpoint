resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_config.name
  resource_group_name      = var.storage_account_config.resource_group_name
  location                 = var.storage_account_config.location
  account_tier             = var.storage_account_config.account_tier
  account_replication_type = var.storage_account_config.account_replication_type
  public_network_access = var.storage_account_config.public_network_access
  allow_nested_items_to_be_public = var.storage_account_config.allow_nested_items_to_be_public
}
