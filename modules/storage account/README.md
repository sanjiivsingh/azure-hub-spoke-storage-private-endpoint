# Azure Storage Account Terraform Child Module

## Overview

The `storage account` child module provisions an [Azure Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview) (`azurerm_storage_account`) configured specifically for enterprise zero-trust networking.

---

## Features

- **Public Network Access Control**: Supports explicit disabling of public internet endpoints (`public_network_access = "Disabled"`), enforcing private-only ingress via Azure Private Link.
- **Nested Public Access Lockdown**: Restricts blob containers and blobs from having public anonymous read access (`allow_nested_items_to_be_public = false`).
- **Flexible SKU & Replication**: Configurable tier (`Standard`, `Premium`) and redundancy model (`LRS`, `GRS`, `ZRS`, `GZRS`). In `dev`, Geo-Redundant Storage (`GRS`) is configured.
- **Full ARM Output**: Exports the complete storage account object, including `id`, primary endpoints, and primary connection strings for dependent modules (Blob Containers and Private Endpoints).

---

## Architecture Role

In this architecture:
- **Instance**: `stonepsdev01` (globally unique naming convention).
- **Network Hardening**: `public_network_access = "Disabled"`, ensuring no direct requests over the public internet can reach the storage account.
- **Private Link Target**: Serves as the target service for the Azure Private Endpoint (`pe-oneps-dev-01`) via subresource `blob`.

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `storage_account_config` | Configuration object defining storage account parameters. | <pre>object({<br>  name                            = string<br>  location                        = string<br>  resource_group_name             = string<br>  account_tier                    = string<br>  account_replication_type        = string<br>  public_network_access           = optional(string)<br>  allow_nested_items_to_be_public = optional(bool)<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `name` (`string`): Globally unique storage account name (3-24 lowercase alphanumeric characters, e.g., `stonepsdev01`).
- `location` (`string`): Azure region (e.g., `central india`).
- `resource_group_name` (`string`): Name of the parent resource group.
- `account_tier` (`string`): Performance tier (`Standard` or `Premium`).
- `account_replication_type` (`string`): Redundancy option (`LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS`).
- `public_network_access` (`optional(string)`): Toggles public ingress (`"Enabled"` or `"Disabled"`). Set to `"Disabled"` for zero-trust private link isolation.
- `allow_nested_items_to_be_public` (`optional(bool)`): Enforces that no blobs or containers inside the storage account can ever be publicly read (`false`).

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `storage_account_output` | Complete `azurerm_storage_account` resource object with `id`, `name`, `primary_blob_endpoint`, etc. | `object` | Yes (contains access keys) |

---

## Usage Example

```hcl
module "storage_account" {
  source = "../../modules/storage account"

  storage_account_config = {
    name                            = "stonepsdev01"
    resource_group_name             = "rg-oneps-dev-01"
    location                        = "central india"
    account_tier                    = "Standard"
    account_replication_type        = "GRS"
    public_network_access           = "Disabled"
    allow_nested_items_to_be_public = false
  }
}

# Accessing the Storage Account ID for Private Endpoint attachment
output "storage_account_id" {
  value = module.storage_account.storage_account_output.id
}
```

