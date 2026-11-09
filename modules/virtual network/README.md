# Azure Virtual Network Terraform Child Module

## Overview

The `virtual network` child module provisions an [Azure Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) (`azurerm_virtual_network`). It establishes the private network boundary and IP addressing spaces required for the Hub-and-Spoke architecture.

---

## Features

- **Custom Address Spaces**: Accepts multiple CIDR blocks for flexible IP planning.
- **Resource Group Association**: Dynamically anchors into the parent resource group.
- **Full Output Exposure**: Exports the complete virtual network resource (ID, name, address spaces, GUID) for subnet provisioning, peering, and DNS zone link associations.

---

## Architecture Role

In this implementation, the module is instantiated twice via `for_each`:
1. **Hub Virtual Network (`hubvnet1`)**:
   - Name: `vnet-oneps-dev-hub01`
   - Address Space: `10.124.0.0/16`
   - Purpose: Central transit network hosting the Private Endpoint subnet.
2. **Spoke Virtual Network (`spokevnet1`)**:
   - Name: `vnet-oneps-dev-spoke01`
   - Address Space: `10.125.0.0/16`
   - Purpose: Workload network hosting application VMs and database tiers.

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `virtual_network_config` | Configuration object defining the virtual network parameters. | <pre>object({<br>  name                = string<br>  resource_group_name = string<br>  location            = string<br>  address_space       = list(string)<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `name` (`string`): Virtual Network name (e.g., `vnet-oneps-dev-hub01`).
- `resource_group_name` (`string`): Name of the parent resource group.
- `location` (`string`): Azure region (e.g., `central india`).
- `address_space` (`list(string)`): List of IPv4 address ranges in CIDR format (e.g., `["10.124.0.0/16"]`).

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `virtual_network_output` | Complete `azurerm_virtual_network` object with `id`, `name`, `address_space`, `subnets`, etc. | `object` | No |

---

## Usage Example

```hcl
module "virtual_network" {
  source = "../../modules/virtual network"

  virtual_network_config = {
    name                = "vnet-oneps-dev-hub01"
    resource_group_name = "rg-oneps-dev-01"
    location            = "central india"
    address_space       = ["10.124.0.0/16"]
  }
}

# Accessing attributes
output "hub_vnet_id" {
  value = module.virtual_network.virtual_network_output.id
}
```
