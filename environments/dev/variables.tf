variable "environment" {
  description = "The environment for which to create resources"
  type        = string
}
variable "project" {
  description = "The project for which to create resources"
  type        = string
}
variable "location" {
  description = "The Azure region in which to create resources"
  type        = string
  default     = "central india"
  validation {
    condition = contains(var.allowed_locations, var.location)
    error_message = format(
      "\u001b[33mUnsupported Azure location.\u001b[0m \nSupported locations are:\n\u001b[32m%s\u001b[0m",
      join(", ", var.allowed_locations)
    )
  }
}

variable "allowed_locations" {
  description = "List of allowed Azure regions for resource creation"
  type        = list(string)
  default     = ["south India", "central india", "west india"]
}


variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_config" {
  description = "Configuration for the resource group"
  type = map(object({
    name_suffix = string
  }))
}

variable "storage_account_config" {
  description = "Configuration for the storage account"
  type = map(object({
    name_suffix                     = string
    rg_key                          = string
    public_network_access           = optional(string)
    allow_nested_items_to_be_public = optional(bool)
  }))
}

variable "container_config" {
  description = "Configuration for the storage container"
  type = map(object({
    name_suffix           = string
    st_key                = string
    container_access_type = string
  }))
}

variable "virtual_network_config" {
  description = "Configuration for the virtual network"
  type = map(object({
    name_suffix   = string
    rg_key        = string
    address_space = list(string)
  }))
}

variable "subnet_config" {
  description = "Configuration for the subnet"
  type = map(object({
    name_suffix                       = string
    vnet_key                          = string
    subnet_num                        = number
    subnet_prefix                     = number
    private_endpoint_network_policies = optional(string)
  }))
}

variable "vnet_peering_config" {
  description = "Configuration for the virtual network peering"
  type = map(object({
    name_suffix     = string
    vnet_key        = string
    remote_vnet_key = string
    rg_key          = string
  }))
}

variable "private_dns_zone_config" {
  description = "Configuration for the private DNS zone"
  type = map(object({
    name   = string
    rg_key = string
  }))
}

variable "private_dns_zone_vnet_link_config" {
  description = "Configuration for the private DNS zone virtual network link"
  type = map(object({
    name_suffix          = string
    pdz_key              = string
    vnet_key             = string
    registration_enabled = bool
  }))
}

variable "private_endpoint_config" {
  description = "Configuration for the private endpoint"
  type = map(object({
    name_suffix                                  = string
    rg_key                                       = string
    st_key                                       = string
    subnet_key                                   = string
    pdz_key                                      = string
    is_manual_connection                         = bool
    private_service_connection_name              = string
    private_service_connection_subresource_names = list(string)
    private_dns_zone_group_name                  = string
  }))
}

variable "virtual_machines_config" {
  description = "Configuration for the Windows virtual machine"
  type = map(object({
    vm_os             = string
    vm_name_suffix    = string
    vm_size           = string
    rg_key            = string
    subnet_key        = string
    public_ip_enabled = optional(bool, false)
    nsg_rules = map(object({
      name                   = string
      priority               = number
      direction              = string
      access                 = string
      protocol               = string
      destination_port_range = optional(string)
    }))
  }))
}

variable "key_vault_details" {
  description = "Details for the Key Vault"
  type = object({
    key_vault_name      = string
    resource_group_name = string
    secrets = object({
      vm_username = string
      vm_password = string
    })
  })
}
