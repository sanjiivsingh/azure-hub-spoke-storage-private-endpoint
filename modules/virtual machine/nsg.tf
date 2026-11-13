resource "azurerm_network_security_group" "this" {
  name                = var.virtual_machine_config.nsg_name
  location            = var.virtual_machine_config.location
  resource_group_name = var.virtual_machine_config.resource_group_name

  dynamic "security_rule" {
    iterator = rule
    for_each = var.virtual_machine_config.nsg_rules 

    content {
      name                       = rule.value.name
      priority                   = rule.value.priority
      direction                  = rule.value.direction
      access                     = rule.value.access
      protocol                   = rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = rule.value.destination_port_range
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}