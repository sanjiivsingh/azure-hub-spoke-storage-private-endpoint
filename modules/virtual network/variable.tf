variable "virtual_network_config" {
  description = "Configuration for the virtual network"
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
  })
}
