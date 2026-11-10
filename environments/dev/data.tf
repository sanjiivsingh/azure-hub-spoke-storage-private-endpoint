data "azurerm_key_vault" "this" {
  name                = var.key_vault_details.key_vault_name
  resource_group_name = var.key_vault_details.resource_group_name
}
data "azurerm_key_vault_secret" "vm_username" {
  name         = var.key_vault_details.secrets.vm_username
  key_vault_id = data.azurerm_key_vault.this.id
}
data "azurerm_key_vault_secret" "vm_password" {
  name         = var.key_vault_details.secrets.vm_password
  key_vault_id = data.azurerm_key_vault.this.id
}