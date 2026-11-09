# Azure Private Endpoint Terraform Child Module

## Overview

The `private endpoint` child module provisions an [Azure Private Endpoint](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) (`azurerm_private_endpoint`). It connects a virtual network privately and securely to an Azure PaaS service—in this architecture, an Azure Storage Account—via [Azure Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview).

---

## Features

- **Private Link Ingress**: Projects a private network interface (NIC) with a private IP into a dedicated subnet.
- **Private Service Connection**: Configures targeted subresource connections (e.g., `["blob"]`) with automatic or manual approval flows (`is_manual_connection = false`).
- **Integrated Private DNS Zone Group**: Bundles the `private_dns_zone_group` block, ensuring that when the endpoint is created, Azure automatically registers the allocated private IP as an `A` record inside the Private DNS Zone (`privatelink.blob.core.windows.net`).
- **Comprehensive Outputs**: Returns the private endpoint object, including allocated private IP addresses, network interface IDs, and FQDN records.

---

## Architecture Role

In this architecture:
- **Name**: `pe-oneps-dev-01`
- **Subnet**: Attached to `subnet-oneps-dev-pe01` in the Hub VNet (`10.124.1.0/24`).
- **Target Service**: Azure Storage Account `stonepsdev01` (subresource: `blob`).
- **Connection Name**: `psc1`.
- **DNS Integration**: Configured with `private_dns_zone_group` named `pdzgroup1`, registering into `privatelink.blob.core.windows.net`.

```
Hub VNet (10.124.0.0/16)
   └── Subnet: subnet-oneps-dev-pe01 (10.124.1.0/24)
          └── Private Endpoint (pe-oneps-dev-01)
                 ├── Private IP NIC: 10.124.1.4 (or 10.124.2.4)
                 ├── Private Service Connection: "psc1" (subresource: "blob")
                 └── Private DNS Zone Group: "pdzgroup1"
```

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `private_endpoint_config` | Configuration object defining the Private Endpoint parameters. | <pre>object({<br>  name                                         = string<br>  resource_group_name                          = string<br>  location                                     = string<br>  subnet_id                                    = string<br>  private_service_connection_name              = string<br>  private_connection_resource_id               = string<br>  private_service_connection_subresource_names = list(string)<br>  is_manual_connection                         = bool<br>  private_dns_zone_ids                         = optional(list(string))<br>  private_dns_zone_group_name                  = optional(string)<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `name` (`string`): Private Endpoint name.
- `resource_group_name` (`string`): Parent resource group.
- `location` (`string`): Azure region.
- `subnet_id` (`string`): Resource ID of the subnet hosting the endpoint.
- `private_service_connection_name` (`string`): Name of the private service connection link (e.g., `psc1`).
- `private_connection_resource_id` (`string`): Resource ID of the target PaaS resource (e.g., storage account ID).
- `private_service_connection_subresource_names` (`list(string)`): Subresource target (e.g., `["blob"]`, `["file"]`, `["table"]`, `["queue"]`).
- `is_manual_connection` (`bool`): Set to `false` for automatic approval within the same Azure tenant/subscription.
- `private_dns_zone_ids` (`optional(list(string))`): List of Private DNS Zone IDs for automatic record management.
- `private_dns_zone_group_name` (`optional(string)`): Name for the Private DNS Zone Group.

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `private_endpoint_output` | Complete `azurerm_private_endpoint` resource object containing `id`, `custom_dns_configs`, `private_dns_zone_configs`, and network interface details. | `object` | No |

---

## Usage Example

```hcl
module "private_endpoint" {
  source = "../../modules/private endpoint"

  private_endpoint_config = {
    name                                         = "pe-oneps-dev-01"
    resource_group_name                          = "rg-oneps-dev-01"
    location                                     = "central india"
    subnet_id                                    = module.subnet["pesubnet1"].subnet_output.id
    private_service_connection_name              = "psc1"
    private_connection_resource_id               = module.storage_account["storage_account1"].storage_account_output.id
    private_service_connection_subresource_names = ["blob"]
    is_manual_connection                         = false
    private_dns_zone_group_name                  = "pdzgroup1"
    private_dns_zone_ids                         = [module.private_dns_zone["dns_zone1"].private_dns_zone_output.id]
  }
}
```
