output "windows_vm_public_ip" {
  value = {
    for key, value in var.virtual_machine_windows_config : key => {
      public_ip_address_id = value.public_ip_enabled == true ? module.virtual_machine_windows[key].vm_public_ip_output[0].ip_address : null
    }
  }
}