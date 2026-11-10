locals {

  # Prefix for resource names
  rg_name_prefix              = "rg-${var.project}-${var.environment}"
  storage_account_name_prefix = "st${var.project}${var.environment}"
  vnet_name_prefix            = "vnet-${var.project}-${var.environment}"
  subnet_name_prefix          = "subnet-${var.project}-${var.environment}"
  dns_zone_name_prefix        = "dns-${var.project}-${var.environment}"
  pvt_endpoint_name_prefix    = "pe-${var.project}-${var.environment}"
  vnet_peering_name_prefix    = "vnetpeering-${var.project}-${var.environment}"
  container_name_prefix       = "container-${var.project}-${var.environment}"
  vm_windows_name_prefix      = "vmw-${var.project}"


  # Resource group configuration
  resource_group = {
    for key, value in var.resource_group_config : key => {
      name     = "${local.rg_name_prefix}-${value.name_suffix}"
      location = var.location
    }
  }

  # Storage account configuration
  storage_account = {
    for key, value in var.storage_account_config : key => {
      name                            = "${local.storage_account_name_prefix}${value.name_suffix}"
      resource_group_name             = module.resource_group[value.rg_key].resource_group_output.name
      location                        = var.location
      account_tier                    = "Standard"
      account_replication_type        = "GRS"
      public_network_access           = value.public_network_access
      allow_nested_items_to_be_public = value.allow_nested_items_to_be_public
    }
  }

  # Container configuration
  container = {
    for key, value in var.container_config : key => {
      name                  = "${local.container_name_prefix}-${value.name_suffix}"
      storage_account_id    = module.storage_account[value.st_key].storage_account_output.id
      container_access_type = value.container_access_type
    }
  }

  # Virtual network configuration
  virtual_network = {
    for key, value in var.virtual_network_config : key => {
      name                = "${local.vnet_name_prefix}-${value.name_suffix}"
      resource_group_name = module.resource_group[value.rg_key].resource_group_output.name
      location            = var.location
      address_space       = value.address_space
    }
  }

  # Virtual network peering configuration
  vnet_peering = {
    for key, value in var.vnet_peering_config : key => {
      name                      = "${local.vnet_peering_name_prefix}-${value.name_suffix}"
      resource_group_name       = module.resource_group[value.rg_key].resource_group_output.name
      virtual_network_name      = module.virtual_network[value.vnet_key].virtual_network_output.name
      remote_virtual_network_id = module.virtual_network[value.remote_vnet_key].virtual_network_output.id
    }
  }
  # Subnet Configuration
  subnet = {
    for key, value in var.subnet_config : key => {
      name                 = "${local.subnet_name_prefix}-${value.name_suffix}"
      virtual_network_name = module.virtual_network[value.vnet_key].virtual_network_output.name
      resource_group_name  = module.virtual_network[value.vnet_key].virtual_network_output.resource_group_name
      address_prefixes = [
        cidrsubnet(
          local.virtual_network[value.vnet_key].address_space[0],
          value.subnet_prefix - tonumber(split("/", local.virtual_network[value.vnet_key].address_space[0])[1]),
          value.subnet_num
        )
      ]
      private_endpoint_network_policies = value.private_endpoint_network_policies
    }
  }

  # Private DNS Zone Configuration
  private_dns_zone = {
    for key, value in var.private_dns_zone_config : key => {
      name                = value.name
      resource_group_name = module.resource_group[value.rg_key].resource_group_output.name
    }
  }

  # Private Endpoint Configuration
  private_endpoint = {
    for key, value in var.private_endpoint_config : key => {
      name                                         = "${local.pvt_endpoint_name_prefix}-${value.name_suffix}"
      resource_group_name                          = module.resource_group[value.rg_key].resource_group_output.name
      location                                     = var.location
      subnet_id                                    = module.subnet[value.subnet_key].subnet_output.id
      private_service_connection_name              = value.private_service_connection_name
      private_service_connection_resource_id       = module.storage_account[value.st_key].storage_account_output.id
      private_service_connection_subresource_names = value.private_service_connection_subresource_names
      is_manual_connection                         = value.is_manual_connection
      private_dns_zone_ids                         = [module.private_dns_zone[value.pdz_key].private_dns_zone_output.id]
      private_dns_zone_group_name                  = value.private_dns_zone_group_name
    }
  }

  # Private DNS Zone Virtual Network Link Configuration
  private_dns_zone_vnet_link = {
    for key, value in var.private_dns_zone_vnet_link_config : key => {
      name                 = "${local.dns_zone_name_prefix}-link-${value.name_suffix}"
      private_dns_zone_id  = module.private_dns_zone[value.pdz_key].private_dns_zone_output.id
      virtual_network_id   = module.virtual_network[value.vnet_key].virtual_network_output.id
      registration_enabled = value.registration_enabled
    }
  }

  # Virtual Machine Configuration
  virtual_machine_windows = {
    for key, value in var.virtual_machine_windows_config : key => {
      vm_name             = "${local.vm_windows_name_prefix}-${value.vm_name_suffix}"
      resource_group_name = module.resource_group[value.rg_key].resource_group_output.name
      location            = var.location
      vm_size             = value.vm_size
      admin_username      = data.azurerm_key_vault_secret.vm_username.value
      admin_password      = data.azurerm_key_vault_secret.vm_password.value
      subnet_id           = module.subnet[value.subnet_key].subnet_output.id
      public_ip_enabled   = value.public_ip_enabled
      nic_name            = "${local.vm_windows_name_prefix}-${value.vm_name_suffix}-nic"
      nsg_name            = "${local.vm_windows_name_prefix}-${value.vm_name_suffix}-nsg"
      nsg_rules           = value.nsg_rules
    }
  }
}
