# Azure Storage Blob Container Terraform Child Module

## Overview

The `blob container` child module provisions an [Azure Storage Container](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) (`azurerm_storage_container`) within a target Azure Storage Account. It provides structured object storage for unstructured data such as logs, documents, and backups.

---

## Features

- **ARM ID Association**: Directly attaches to a storage account via its Azure Resource Manager ID (`storage_account_id`), aligning with modern AzureRM provider conventions.
- **Granular Access Type Control**: Sets access levels (`private`, `blob`, or `container`). When paired with zero-trust storage policies, access is strictly kept `private`.
- **Full Output Exposure**: Exports the container resource object (`id`, `name`, `resource_manager_id`) for downstream data ingestion or RBAC role assignments.

---

## Architecture Role

In this architecture:
- **Instance**: `container-oneps-dev-01` (representing `oneps-docs` in the architecture diagram).
- **Security Policy**: `container_access_type = "private"`.
- **Access Route**: Accessible exclusively through the private endpoint from authenticated clients residing in authorized VNets (such as the Spoke VM).

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `container_config` | Configuration object defining the storage container parameters. | <pre>object({<br>  name                  = string<br>  storage_account_id    = string<br>  container_access_type = string<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `name` (`string`): Name of the blob container (e.g., `container-oneps-dev-01`).
- `storage_account_id` (`string`): The Resource ID of the parent Azure Storage Account.
- `container_access_type` (`string`): Access level for the container (`private`, `blob`, or `container`). In secure private link environments, this must be set to `"private"`.

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `container_output` | Complete `azurerm_storage_container` resource object. | `object` | No |

---

## Usage Example

```hcl
module "blob_container" {
  source = "../../modules/blob container"

  container_config = {
    name                  = "container-oneps-dev-01"
    storage_account_id    = module.storage_account["storage_account1"].storage_account_output.id
    container_access_type = "private"
  }
}
```

