# Azure Resource Group Terraform Child Module

## Overview

The `resource group` child module provisions an [Azure Resource Group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview) (`azurerm_resource_group`). In this architecture, it serves as the foundational logical container for all network infrastructure, storage services, private endpoints, and compute workloads.

---

## Features

- **Encapsulated Object Input**: Consolidates resource group attributes (`name`, `location`, `tags`) into a strongly-typed object schema.
- **Dynamic Tagging**: Supports optional resource tags for metadata, cost allocation, and environment tracking.
- **Full Resource Export**: Exposes the complete resource group object output for seamless downstream dependency wiring (e.g., retrieving `.name` and `.location`).

---

## Architecture Role

In the Hub-and-Spoke Private Endpoint architecture:
- Groups the Hub Virtual Network (`vnet-oneps-dev-hub01`), Spoke Virtual Network (`vnet-oneps-dev-spoke01`), Azure Storage Account (`stonepsdev01`), Private Endpoint (`pe-oneps-dev-01`), Private DNS Zone (`privatelink.blob.core.windows.net`), and Test Windows VM (`vmw-oneps-01`).
- Ensures consistent regional placement (`central india` in `dev`).

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `resource_group_config` | Configuration object defining the resource group properties. | <pre>object({<br>  name     = string<br>  location = string<br>  tags     = optional(map(string))<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `name` (`string`): The name of the Azure Resource Group (e.g., `rg-oneps-dev-01`).
- `location` (`string`): Azure region where the resource group is created (e.g., `central india`).
- `tags` (`optional(map(string))`): Key-value pairs for organizational tagging.

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `resource_group_output` | The full `azurerm_resource_group` object containing `id`, `name`, `location`, etc. | `object` | No |

---

## Usage Example

```hcl
module "resource_group" {
  source = "../../modules/resource group"

  resource_group_config = {
    name     = "rg-oneps-dev-01"
    location = "central india"
    tags = {
      environment = "dev"
      project     = "oneps"
      managedby   = "terraform"
    }
  }
}

# Consuming the output downstream
output "rg_name" {
  value = module.resource_group.resource_group_output.name
}
```
