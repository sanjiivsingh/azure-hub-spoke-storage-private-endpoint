variable "virtual_machine_config" {
  description = "Configuration for the Windows virtual machine"
  type = object({
    vm_os                           = string
    vm_name                         = string
    vm_size                         = string
    admin_username                  = string
    admin_password                  = string
    location                        = string
    resource_group_name             = string
    subnet_id                       = string
    nic_name                        = string
    disable_password_authentication = optional(bool, false)
    public_ip_enabled               = optional(bool, false)
    nsg_name                        = string
    nsg_rules = map(object({
      name                   = string
      priority               = number
      direction              = string
      access                 = string
      protocol               = string
      destination_port_range = optional(string, null)
    }))
  })
}
