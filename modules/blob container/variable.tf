variable "container_config" {
  description = "Configuration for the storage container"
  type = object({
    name                  = string
    storage_account_id    = string
    container_access_type = string
  })
}