# ADR 0001: Centralized Hub Placement for Storage Private Endpoints

## Status
**Accepted**

## Context
When designing multi-VNet network topologies on Microsoft Azure (Cloud Adoption Framework / Enterprise Landing Zones), applications running in spoke virtual networks require secure, private access to PaaS services such as Azure Storage Accounts.

There are two primary architectural patterns:
1. **Decentralized Placement**: Deploy a Private Endpoint into each spoke VNet for every PaaS dependency.
2. **Centralized Hub Placement**: Deploy Private Endpoints into a dedicated transit subnet in the Hub VNet and establish bidirectional VNet Peering to spoke networks, backed by linked Private DNS Zones.

## Decision
We adopted the **Centralized Hub Placement** pattern:
- **Private Endpoint Subnet**: Located in the centralized Hub Virtual Network (`10.124.0.0/16`) under subnet `subnet-oneps-dev-pe01` (`10.124.1.0/24`).
- **Private DNS Zone**: Centralized zone `privatelink.blob.core.windows.net` linked to both Hub and Spoke virtual networks.
- **Interconnect**: Bidirectional VNet Peering connects Hub and Spoke networks directly across Microsoft's private global backbone.
- **Dynamic Endpoint Grouping**: Uses `private_dns_zone_group` on the Private Endpoint to automatically populate the `A` record upon IP allocation.

## Consequences

### Positive
- **Cost Optimization**: Shared Private Endpoints eliminate endpoint duplication across multiple workload spokes.
- **Centralized Security Inspection**: Ingress to storage services passes through the Hub boundary, enabling future insertion of Azure Firewall, IDS/IPS, or Network Virtual Appliances (NVAs) via User-Defined Routes (UDRs).
- **Simplified DNS Architecture**: A single Private DNS Zone serves all peered virtual networks without fragmented split-horizon configurations.
- **Zero-Public Hardening**: Public network access is completely disabled on the storage account (`public_network_access = "Disabled"`), enforcing Private Link as the sole ingress route.

### Trade-offs & Mitigations
- **Cross-VNet Data Transfer**: Traffic traversing VNet Peering incurs standard Azure VNet peering data transfer fees.
  - *Mitigation*: Negligible compared to duplicate endpoint charges; optimized by keeping intra-region latency sub-millisecond.
- **Subnet Policy Constraints**: Private Endpoints historically required disabling subnet network policies (`private_endpoint_network_policies = "Disabled"`).
  - *Mitigation*: Handled explicitly in the subnet child module.
