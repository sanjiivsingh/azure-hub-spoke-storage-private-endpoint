variable "storage_account_config" {
    description = "Configuration for the storage account"
    type        = object({
        name     = string
        location = string
        resource_group_name = string
        account_tier = string
        account_replication_type = string
        public_network_access = optional(string)
        allow_nested_items_to_be_public = optional(bool)
    })
}