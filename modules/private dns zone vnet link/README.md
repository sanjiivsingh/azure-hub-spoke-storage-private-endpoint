# Azure Private DNS Zone VNet Link Terraform Child Module

## Overview

The `private dns zone vnet link` child module provisions an [Azure Private DNS Zone Virtual Network Link](https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links) (`azurerm_private_dns_zone_virtual_network_link`). It links an Azure Private DNS Zone to a specific Virtual Network, enabling VMs and services within that VNet to resolve domain names managed by the zone.

---

## Features

- **Bidirectional Resolution Scope**: Allows any connected VNet to resolve custom or Azure Private Link domain records.
- **Auto-Registration Support**: Configurable `registration_enabled` flag to automatically register VM hostnames into the DNS zone if required.
- **Resource Export**: Returns the complete link object including `id` and resolution state.

---

## Architecture Role

In this architecture, two distinct links are established to ensure full DNS resolution across the topology:

```
Private DNS Zone: privatelink.blob.core.windows.net
    ├── Link 1: Hub VNet (registration_enabled = true)
    └── Link 2: Spoke VNet (registration_enabled = false)
```

1. **`link1` (`dns-oneps-dev-link-01`)**:
   - Linked to: `vnet-oneps-dev-hub01`
   - `registration_enabled = true`
   - Enables resources inside the Hub to resolve Private Link records.
2. **`link2` (`dns-oneps-dev-link-02`)**:
   - Linked to: `vnet-oneps-dev-spoke01`
   - `registration_enabled = false` (resolution-only link; spoke workload VMs resolve the Private Link A-record without auto-registering their own hostnames).

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `dns_zone_vnet_link_config` | Configuration object defining the DNS VNet link parameters. | <pre>object({<br>  name                 = string<br>  private_dns_zone_id  = string<br>  virtual_network_id   = string<br>  registration_enabled = bool<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `name` (`string`): Name of the VNet link resource.
- `private_dns_zone_id` (`string`): Resource ID of the parent Private DNS Zone.
- `virtual_network_id` (`string`): Resource ID of the target Virtual Network to be linked.
- `registration_enabled` (`bool`): Whether auto-registration of virtual machine records is enabled (`true` or `false`).

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `private_dns_vnet_link_output` | Complete `azurerm_private_dns_zone_virtual_network_link` resource object. | `object` | No |

---

## Usage Example

```hcl
module "dns_link_spoke" {
  source = "../../modules/private dns zone vnet link"

  dns_zone_vnet_link_config = {
    name                 = "dns-oneps-dev-link-02"
    private_dns_zone_id  = module.private_dns_zone["dns_zone1"].private_dns_zone_output.id
    virtual_network_id   = module.virtual_network["spokevnet1"].virtual_network_output.id
    registration_enabled = false
  }
}
```

