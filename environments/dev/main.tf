module "resource_group" {
  source                = "../../modules/resource group"
  for_each              = local.resource_group
  resource_group_config = each.value
}

module "storage_account" {
  source                 = "../../modules/storage account"
  for_each               = local.storage_account
  storage_account_config = each.value
}

module "blob_container" {
  source           = "../../modules/blob container"
  for_each         = local.container
  container_config = each.value
}

module "virtual_network" {
  source                 = "../../modules/virtual network"
  for_each               = local.virtual_network
  virtual_network_config = each.value
}

module "virtual_network_peering" {
  source              = "../../modules/virtual network peering"
  for_each            = local.vnet_peering
  vnet_peering_config = each.value
}

module "subnet" {
  source        = "../../modules/subnet"
  for_each      = local.subnet
  subnet_config = each.value
}

module "private_dns_zone" {
  source          = "../../modules/private dns zone"
  for_each        = local.private_dns_zone
  dns_zone_config = each.value
}

module "private_endpoint" {
  source                  = "../../modules/private endpoint"
  for_each                = local.private_endpoint
  private_endpoint_config = each.value
}

module "private_dns_zone_vnet_link" {
  source                    = "../../modules/private dns zone vnet link"
  for_each                  = local.private_dns_zone_vnet_link
  dns_zone_vnet_link_config = each.value
}

module "virtual_machine_windows" {
  source                         = "../../modules/virtual machine"
  for_each                       = local.virtual_machine_windows
  virtual_machine_windows_config = each.value
}

