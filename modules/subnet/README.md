# Azure Subnet Terraform Child Module

## Overview

The `subnet` child module provisions an [Azure Subnet](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet) (`azurerm_subnet`) within a specified Virtual Network. It supports address prefix assignment and configurable `private_endpoint_network_policies` necessary for Azure Private Link endpoints.

---

## Features

- **Decoupled Architecture**: Subnets are provisioned independently from virtual network definitions, avoiding cyclic configuration dependencies.
- **Private Endpoint Compatibility**: Configurable `private_endpoint_network_policies` (defaults to `"Disabled"`), allowing seamless deployment of Azure Private Endpoints.
- **CIDR Flexibility**: Supports any standard IPv4 subnet prefix list.
- **Resource Export**: Exports the complete subnet object (ID, address prefixes, name) for network interfaces and private endpoint bindings.

---

## Architecture Role

In this architecture, three subnets are dynamically calculated and provisioned using Terraform's `cidrsubnet()` function:

| Subnet Key | Subnet Name | Parent VNet | CIDR | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `pesubnet1` | `subnet-oneps-dev-pe01` | Hub (`10.124.0.0/16`) | `10.124.1.0/24` | Dedicated Private Endpoint subnet (`private_endpoint_network_policies = "Disabled"`). |
| `appsubnet1` | `subnet-oneps-dev-app01` | Spoke (`10.125.0.0/16`) | `10.125.1.0/24` | Application tier subnet hosting the Windows VM (`vm-oneps-win01`). |
| `dbsubnet1` | `subnet-oneps-dev-db01` | Spoke (`10.125.0.0/16`) | `10.125.2.0/24` | Database/workload subnet hosting the Ubuntu Linux VM (`vm-oneps-lin01`). |

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `subnet_config` | Configuration object defining the subnet parameters. | <pre>object({<br>  name                              = string<br>  virtual_network_name              = string<br>  resource_group_name               = string<br>  address_prefixes                  = list(string)<br>  private_endpoint_network_policies = optional(string, "Disabled")<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `name` (`string`): Name of the subnet.
- `virtual_network_name` (`string`): Name of the parent Virtual Network.
- `resource_group_name` (`string`): Name of the parent Resource Group.
- `address_prefixes` (`list(string)`): CIDR address prefixes allocated to the subnet.
- `private_endpoint_network_policies` (`optional(string)`): Policy enforcement on private endpoints (`Disabled`, `Enabled`, `NetworkSecurityGroupEnabled`). Defaults to `"Disabled"`.

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `subnet_output` | Complete `azurerm_subnet` object including `id`, `name`, `address_prefixes`. | `object` | No |

---

## Usage Example

```hcl
module "subnet" {
  source = "../../modules/subnet"

  subnet_config = {
    name                              = "subnet-oneps-dev-pe01"
    virtual_network_name              = "vnet-oneps-dev-hub01"
    resource_group_name               = "rg-oneps-dev-01"
    address_prefixes                  = ["10.124.1.0/24"]
    private_endpoint_network_policies = "Disabled"
  }
}

# Subnet ID consumption
output "pe_subnet_id" {
  value = module.subnet.subnet_output.id
}
```

