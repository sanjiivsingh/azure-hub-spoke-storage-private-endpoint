variable "private_endpoint_config" {
  description = "Configuration for the private endpoint"
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    subnet_id           = string
    private_service_connection_name = string
    private_service_connection_resource_id = string
    private_service_connection_subresource_names = list(string)
    is_manual_connection = bool
    private_dns_zone_ids = optional(list(string))
    private_dns_zone_group_name = optional(string)
  })
}