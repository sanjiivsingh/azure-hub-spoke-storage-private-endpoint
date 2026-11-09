# Azure Windows Virtual Machine Terraform Child Module

## Overview

The `virtual machine` child module provisions an [Azure Windows Virtual Machine](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/overview) (`azurerm_windows_virtual_machine`) bundled with its dedicated Network Interface (NIC), an optional Static Public IP, a Network Security Group (NSG) with dynamic firewall rules, and a NIC-to-NSG association.

---

## Features

- **Integrated Compute Stack**: Manages the complete VM lifecycle (NIC, Public IP, NSG, Security Rules, VM instance) in a single cohesive child module.
- **Dynamic NSG Firewall Engine**: Supports declarative security rules via dynamic blocks (e.g., controlling inbound RDP / port 3389).
- **Conditional Public IP**: Dynamically toggles static public IP creation via `public_ip_enabled`. When enabled, associates the public IP to the NIC for remote management.
- **Enterprise Image Baseline**: Uses Windows Server 2016 Datacenter with Standard LRS managed OS disk storage.

---

## Architecture Role

In this architecture:
- **Instance**: `vmw-oneps-01`
- **Location**: Deployed into the Spoke VNet within `subnet-oneps-dev-app01` (`10.125.1.0/24`).
- **Function**: Acts as the client/application workload node that tests and proves private connectivity to the Azure Storage Account via Private Link:
  1. Issues DNS query for `stonepsdev01.blob.core.windows.net`.
  2. Resolves private IP (`10.124.1.4` / `10.124.2.4`) through Private DNS Zone link.
  3. Transmits requests across the VNet peering directly to the Hub Private Endpoint.
- **Access**: Configured with a static Public IP and NSG allowing RDP (Port 3389) for administrator testing and verification.

---

## Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `virtual_machine_windows_config` | Configuration object defining the VM, NIC, Public IP, and NSG. | <pre>object({<br>  vm_name              = string<br>  vm_size              = string<br>  admin_username       = string<br>  admin_password       = string<br>  location             = string<br>  resource_group_name  = string<br>  subnet_id            = string<br>  nic_name             = string<br>  public_ip_enabled    = optional(bool, false)<br>  nsg_name             = string<br>  nsg_rules            = map(object({<br>    name                   = string<br>    priority               = number<br>    direction              = string<br>    access                 = string<br>    protocol               = string<br>    destination_port_range = optional(string, null)<br>  }))<br>})</pre> | **Yes** | N/A |

### Input Object Attributes

- `vm_name` (`string`): Virtual machine host name (e.g., `vmw-oneps-01`).
- `vm_size` (`string`): Azure VM compute SKU (e.g., `Standard_D4_v5`).
- `admin_username` (`string`): Local administrator account username.
- `admin_password` (`string`): Local administrator account password.
- `location` (`string`): Azure region.
- `resource_group_name` (`string`): Resource group name.
- `subnet_id` (`string`): Subnet ID where the VM NIC attaches.
- `nic_name` (`string`): Name of the network interface.
- `public_ip_enabled` (`optional(bool)`): Whether to allocate and attach a public IP address (default: `false`).
- `nsg_name` (`string`): Name of the Network Security Group.
- `nsg_rules` (`map(object)`): Map of security rule definitions with `priority`, `direction`, `access`, `protocol`, and `destination_port_range`.

---

## Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `vm_windows_output` | Complete `azurerm_network_interface` resource object. | `object` | No |
| `vm_public_ip_output` | List containing the `azurerm_public_ip` resource object (if created), or empty list. | `list` | No |

---

## Usage Example

```hcl
module "virtual_machine_windows" {
  source = "../../modules/virtual machine"

  virtual_machine_windows_config = {
    vm_name             = "vmw-oneps-01"
    vm_size             = "Standard_D4_v5"
    admin_username      = "adminuser"
    admin_password      = "ComplexP@ssw0rd!"
    location            = "central india"
    resource_group_name = "rg-oneps-dev-01"
    subnet_id           = module.subnet["appsubnet1"].subnet_output.id
    nic_name            = "vmw-oneps-01-nic"
    public_ip_enabled   = true
    nsg_name            = "vmw-oneps-01-nsg"
    nsg_rules = {
      "rdp" = {
        name                   = "RDP"
        priority               = 1000
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "Tcp"
        destination_port_range = "3389"
      }
    }
  }
}
```
