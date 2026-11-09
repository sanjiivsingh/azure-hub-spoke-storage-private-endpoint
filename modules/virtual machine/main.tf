resource "azurerm_network_interface" "this" {
  name                = var.virtual_machine_windows_config.nic_name
  location            = var.virtual_machine_windows_config.location
  resource_group_name = var.virtual_machine_windows_config.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.virtual_machine_windows_config.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.virtual_machine_windows_config.public_ip_enabled == true ? azurerm_public_ip.this[0].id : null
  }
}

resource "azurerm_public_ip" "this" {
  count               = var.virtual_machine_windows_config.public_ip_enabled == true ? 1 : 0
  name                = "${var.virtual_machine_windows_config.vm_name}-public-ip"
  location            = var.virtual_machine_windows_config.location
  resource_group_name = var.virtual_machine_windows_config.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_windows_virtual_machine" "this" {
  name                = var.virtual_machine_windows_config.vm_name
  resource_group_name = var.virtual_machine_windows_config.resource_group_name
  location            = var.virtual_machine_windows_config.location
  size                = var.virtual_machine_windows_config.vm_size
  admin_username      = var.virtual_machine_windows_config.admin_username
  admin_password      = var.virtual_machine_windows_config.admin_password
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "this" {
  name                = var.virtual_machine_windows_config.nsg_name
  location            = var.virtual_machine_windows_config.location
  resource_group_name = var.virtual_machine_windows_config.resource_group_name

  dynamic "security_rule" {
    iterator = rule
    for_each = var.virtual_machine_windows_config.nsg_rules

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
