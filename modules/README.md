# Reusable Azure Terraform Child Modules

This directory contains 10 decoupled, enterprise-grade Terraform child modules designed to implement Zero-Trust Azure networking, private storage endpoints, and workload compute verification.

---

## Module Catalog

| # | Child Module | Primary Azure Resource | Key Purpose |
| :-: | :--- | :--- | :--- |
| 1 | [`resource group`](./resource%20group/README.md) | `azurerm_resource_group` | Provisions the logical lifecycle and regional boundary for all infrastructure resources. |
| 2 | [`virtual network`](./virtual%20network/README.md) | `azurerm_virtual_network` | Provisions virtual networks for Hub transit and Spoke workload isolation. |
| 3 | [`subnet`](./subnet/README.md) | `azurerm_subnet` | Creates subnets with configurable `private_endpoint_network_policies`. |
| 4 | [`virtual network peering`](./virtual%20network%20peering/README.md) | `azurerm_virtual_network_peering` | Establishes private, high-speed backbone peering between Hub and Spoke networks. |
| 5 | [`storage account`](./storage%20account/README.md) | `azurerm_storage_account` | Deploys a hardened storage account with public internet access disabled. |
| 6 | [`blob container`](./blob%20container/README.md) | `azurerm_storage_container` | Creates private blob containers for secure object storage. |
| 7 | [`private dns zone`](./private%20dns%20zone/README.md) | `azurerm_private_dns_zone` | Authoritative DNS zone (`privatelink.blob.core.windows.net`) for internal name resolution. |
| 8 | [`private dns zone vnet link`](./private%20dns%20zone%20vnet%20link/README.md) | `azurerm_private_dns_zone_virtual_network_link` | Links Private DNS zones to Hub and Spoke VNets with optional registration. |
| 9 | [`private endpoint`](./private%20endpoint/README.md) | `azurerm_private_endpoint` | Provisions Private Endpoint with Private Service Connection and DNS Zone Group integration. |
| 10 | [`virtual machine`](./virtual%20machine/README.md) | `azurerm_windows_virtual_machine` | Provisions Windows VM, NIC, Public IP, and NSG for workload verification. |

---

## Architectural Design Principles

1. **Strict Decoupling**: Each module manages exactly one core resource or tightly-coupled resource cluster (e.g., VM + NIC + NSG).
2. **Object-Based Interface**: Each module accepts a consolidated `*_config` object, preventing parameter explosion and simplifying environment-level composition via `for_each`.
3. **Explicit Dependency Injection**: Modules do not hardcode foreign resource references; instead, values such as subnet IDs, resource group names, and DNS zone IDs are passed in from the environment layer.
4. **Zero-Trust Hardening**: Default policies prioritize disabled public network access, private containers, and dedicated private endpoint subnets.

