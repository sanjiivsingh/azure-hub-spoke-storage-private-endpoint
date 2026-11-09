variable "vnet_peering_config" {
  description = "Configuration for the virtual network peering"
  type = object({
    name                      = string
    resource_group_name       = string
    virtual_network_name      = string
    remote_virtual_network_id = string
  })  
}