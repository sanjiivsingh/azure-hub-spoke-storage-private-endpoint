variable "dns_zone_vnet_link_config" {
  description = "Configuration for the private DNS zone virtual network link"
    type = object({
        name                = string
        private_dns_zone_id = string
        virtual_network_id  = string
        registration_enabled = bool
    })
}