resource "azurerm_storage_container" "this" {
  name                  = var.container_config.name
  storage_account_id    = var.container_config.storage_account_id
  container_access_type = var.container_config.container_access_type
}
