output "vm_windows_output" {
  value = azurerm_network_interface.this
}

output "vm_public_ip_output" {
  value = azurerm_public_ip.this
}