# Azure Multi-OS Virtual Machine Terraform Child Module

## Overview

The `virtual machine` child module is a multi-OS compute provisioning module designed to deploy either a **Windows Virtual Machine** (`azurerm_windows_virtual_machine`) or an **Ubuntu Linux Virtual Machine** (`azurerm_linux_virtual_machine`).

The module encapsulates the complete compute lifecycle:
- Dedicated Network Interface (`azurerm_network_interface`)
- Optional Static Public IP (`azurerm_public_ip`)
- Network Security Group (`azurerm_network_security_group`) with dynamic firewall rules
- Network Interface to NSG Association (`azurerm_network_interface_security_group_association`)
- OS-specific compute resource selection based on the `vm_os` attribute

---

## 🏗️ Modular Architecture & File Structure

The module is decomposed into focused single-responsibility resource files:

| File | Purpose | Managed Azure Resource |
| :--- | :--- | :--- |
| **`windows.tf`** | Provisions a Windows Server 2016 Datacenter VM when `vm_os == "windows"`. | `azurerm_windows_virtual_machine.this` |
| **`linux.tf`** | Provisions an Ubuntu 22.04 LTS VM when `vm_os == "linux"`. | `azurerm_linux_virtual_machine.this` |
| **`network-interface.tf`** | Configures private IP allocation and dynamic public IP attachment. | `azurerm_network_interface.this` |
| **`public-ip.tf`** | Conditionally creates a static public IP when `public_ip_enabled = true`. | `azurerm_public_ip.this` |
| **`nsg.tf`** | Builds dynamic NSG firewall rules and associates the NSG to the NIC. | `azurerm_network_security_group.this` |
| **`variable.tf`** | Declares the unified `virtual_machine_config` object schema. | N/A |
| **`output.tf`** | Exposes the network interface and public IP outputs. | N/A |

---

## ⚙️ Module Inputs

| Name | Description | Type | Required | Default |
| :--- | :--- | :--- | :---: | :---: |
| `virtual_machine_config` | Configuration object defining the VM, OS type, networking, credentials, and firewall rules. | `object({...})` | **Yes** | N/A |

### Input Object Schema (`virtual_machine_config`)

```hcl
variable "virtual_machine_config" {
  description = "Configuration for the Windows/Linux virtual machine"
  type = object({
    vm_os                           = string
    vm_name                         = string
    vm_size                         = string
    admin_username                  = string
    admin_password                  = string
    location                        = string
    resource_group_name             = string
    subnet_id                       = string
    nic_name                        = string
    disable_password_authentication = optional(bool, false)
    authentication_method           = optional(string, "password")
    public_key                      = optional(string)
    public_ip_enabled               = optional(bool, false)
    nsg_name                        = string
    nsg_rules = map(object({
      name                   = string
      priority               = number
      direction              = string
      access                 = string
      protocol               = string
      destination_port_range = optional(string, null)
    }))
  })

  validation {
    condition = contains(
      ["password", "ssh_key"],
      lower(var.virtual_machine_config.authentication_method)
    )
    error_message = "Authentication method must be either password or ssh_key."
  }
}
```

### Attribute Descriptions

- `vm_os` (`string`): Target operating system. Supported values are `"windows"` or `"linux"` (evaluated case-insensitively via `lower()`).
- `vm_name` (`string`): Virtual machine host name.
- `vm_size` (`string`): Azure VM compute SKU (e.g., `Standard_D4_v5`).
- `admin_username` (`string`): Local administrator account username.
- `admin_password` (`string`): Local administrator account password. Set to `null` automatically on Linux VMs when `authentication_method == "ssh_key"`.
- `authentication_method` (`optional(string, "password")`): Authentication mode. Supported values are `"password"` or `"ssh_key"` (validated via `contains(["password", "ssh_key"], ...)`).
- `public_key` (`optional(string)`): SSH public key string (e.g., RSA 4096-bit). Injected via dynamic `admin_ssh_key` block when `authentication_method == "ssh_key"`.
- `location` (`string`): Azure region for all compute resources.
- `resource_group_name` (`string`): Parent resource group name.
- `subnet_id` (`string`): ARM ID of the subnet to which the NIC attaches.
- `nic_name` (`string`): Name of the Network Interface.
- `disable_password_authentication` (`optional(bool)`): Set automatically to `true` when `authentication_method == "ssh_key"` to enforce passwordless authentication.
- `public_ip_enabled` (`optional(bool)`): Set to `true` to allocate a static public IP; `false` keeps the VM private-only (default: `false`).
- `nsg_name` (`string`): Name of the Network Security Group.
- `nsg_rules` (`map(object)`): Map of inbound/outbound firewall rules evaluated dynamically.

---

## 🌍 Passing Values from the Environment Layer

In the environment layer (e.g., `environments/dev`), values are **never passed raw or hardcoded directly to the child module**. Instead, the environment orchestrates parameters using **loose coupling, naming standards, and Azure Key Vault secret retrieval**.

### Value Source & Resolution Matrix

| Attribute Expected by Child Module | Environment Layer Source | How It Is Resolved |
| :--- | :--- | :--- |
| `vm_os` | `terraform.tfvars` (`value.vm_os`) | Direct parameter (`"windows"` or `"linux"`). |
| `vm_name` | `locals.tf` (`${local.vm_name_prefix}-${value.vm_name_suffix}`) | Enforces Cloud Adoption Framework (CAF) naming standard (`vm-oneps-win01` / `vm-oneps-lin01`). |
| `vm_size` | `terraform.tfvars` (`value.vm_size`) | Direct parameter (e.g., `Standard_D4_v5`). |
| `admin_username` | `data.tf` (Azure Key Vault Secret) | Resolved dynamically via `data.azurerm_key_vault_secret.vm_username.value`. |
| `admin_password` | `data.tf` (Azure Key Vault Secret) | Resolved dynamically via `data.azurerm_key_vault_secret.vm_password[0].value` (when `authentication_method == "password"`). |
| `authentication_method` | `terraform.tfvars` (`value.authentication_method`) | Configured per VM (`"password"` or `"ssh_key"`). |
| `public_key` | `data.tf` (Azure Key Vault Secret) | Resolved dynamically via `data.azurerm_key_vault_secret.ssh_public_key[0].value` (when `authentication_method == "ssh_key"`). |
| `location` | `variables.tf` (`var.location`) | Standardized regional variable (e.g., `central india`). |
| `resource_group_name` | `module.resource_group` output | Resolved dynamically via `module.resource_group[value.rg_key].resource_group_output.name`. |
| `subnet_id` | `module.subnet` output | Resolved dynamically via `module.subnet[value.subnet_key].subnet_output.id`. |
| `nic_name` | `locals.tf` | Standardized naming (`${local.vm_name_prefix}-${value.vm_name_suffix}-nic`). |
| `nsg_name` | `locals.tf` | Standardized naming (`${local.vm_name_prefix}-${value.vm_name_suffix}-nsg`). |
| `public_ip_enabled` | `terraform.tfvars` (`value.public_ip_enabled`) | Boolean toggle controlling public IP allocation. |
| `nsg_rules` | `terraform.tfvars` (`value.nsg_rules`) | Declarative security rules (e.g., port 3389 for RDP or port 22 for SSH). |

---

### Environment Implementation Example

#### 1. Input Declaration in `terraform.tfvars`
```hcl
virtual_machines_config = {
  "windows_vm_01" = {
    vm_os                 = "windows"
    vm_name_suffix        = "win01"
    vm_size               = "Standard_D2as_v5"
    rg_key                = "rg1"
    subnet_key            = "appsubnet1"
    public_ip_enabled     = true
    authentication_method = "password"
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

  "linux_vm_01" = {
    vm_os                 = "LinUX"
    vm_name_suffix        = "lin01"
    vm_size               = "Standard_D2s_v5"
    rg_key                = "rg1"
    subnet_key            = "dbsubnet1"
    public_ip_enabled     = true
    authentication_method = "ssh_key"
    nsg_rules = {
      "ssh" = {
        name                   = "SSH"
        priority               = 300
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "Tcp"
        destination_port_range = "22"
      }
    }
  }
}
```

#### 2. Assembly & Secret Binding in `locals.tf`
```hcl
locals {
  vm_name_prefix = "vm-${var.project}"

  virtual_machine_config = {
    for key, value in var.virtual_machines_config : key => {
      vm_os                 = value.vm_os
      vm_name               = "${local.vm_name_prefix}-${value.vm_name_suffix}"
      resource_group_name   = module.resource_group[value.rg_key].resource_group_output.name
      location              = var.location
      vm_size               = value.vm_size
      admin_username        = data.azurerm_key_vault_secret.vm_username.value
      authentication_method = value.authentication_method
      admin_password        = data.azurerm_key_vault_secret.vm_password[0].value
      public_key            = data.azurerm_key_vault_secret.ssh_public_key[0].value
      subnet_id             = module.subnet[value.subnet_key].subnet_output.id
      public_ip_enabled     = value.public_ip_enabled
      nic_name              = "${local.vm_name_prefix}-${value.vm_name_suffix}-nic"
      nsg_name              = "${local.vm_name_prefix}-${value.vm_name_suffix}-nsg"
      nsg_rules             = value.nsg_rules
    }
  }
}
```

#### 3. Module Call in `main.tf`
```hcl
module "virtual_machines" {
  source                 = "../../modules/virtual machine"
  for_each               = local.virtual_machine_config
  virtual_machine_config = each.value
}
```

---

## 📤 Outputs

| Name | Description | Type | Sensitive |
| :--- | :--- | :--- | :---: |
| `vm_windows_output` | Complete `azurerm_network_interface` resource object. | `object` | No |
| `vm_public_ip_output` | List containing the `azurerm_public_ip` resource object (if created), or empty list. | `list` | No |
