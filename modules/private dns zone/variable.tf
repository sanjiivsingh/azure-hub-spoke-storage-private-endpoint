variable "dns_zone_config" {
    description = "Configuration for the private DNS zone"
  type = object({
    name                = string
    resource_group_name = string
  })
}