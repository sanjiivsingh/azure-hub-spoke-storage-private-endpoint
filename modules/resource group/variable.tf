variable "resource_group_config" {
  type = object({
    name     = string
    location = string
    tags     = optional(map(string))
  })
}