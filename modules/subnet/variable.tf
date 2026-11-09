variable "subnet_config" {
  description = "Configuration for the subnet "
  type = object({
    name                = string
    virtual_network_name = string
    resource_group_name = string
    address_prefixes    = list(string)
    private_endpoint_network_policies = optional(string, "Disabled")
  })
}
