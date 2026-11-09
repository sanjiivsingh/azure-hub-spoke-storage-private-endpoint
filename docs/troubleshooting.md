# Troubleshooting & Operations Runbook

This guide covers common operational challenges, misconfigurations, and diagnostic procedures when deploying and running **Azure Storage Private Link in a Hub-and-Spoke Virtual Network architecture**.

---

## 🛠️ Diagnostics Matrix

| Symptom | Root Cause | Resolution |
| :--- | :--- | :--- |
| **Storage Account FQDN resolves to Public IP** | Missing or unlinked Private DNS Zone Link on the querying VNet. | Ensure `azurerm_private_dns_zone_virtual_network_link` exists for the client's VNet (e.g., `spokevnet1`). |
| **TCP Port 443 Connection Timeout** | VNet peering not in `Connected` status, or NSG blocking port 443 outbound. | Verify bidirectional peering status via Azure CLI / Portal; verify NSG rules allow TCP 443 egress. |
| **Subnet Network Policy Error** | Subnet attempting to host Private Endpoint has policies enabled inappropriately. | Set `private_endpoint_network_policies = "Disabled"` in `subnet_config` for the PE subnet. |
| **HTTP 403 Forbidden with AuthorizationFailure** | Storage account public network access is disabled, but client is not reaching via Private Link. | Confirm request originates from a peered VNet and resolves to the private IP (`10.124.1.4`). |
| **Private DNS Zone missing A-Record** | Private DNS Zone Group not configured on Private Endpoint. | Ensure `private_dns_zone_group` block is populated with the zone resource ID. |

---

## 🔍 Detailed Troubleshooting Scenarios

### Scenario 1: DNS Resolves to Public IP Instead of Private IP

#### Identification
Running `Resolve-DnsName` inside the workload VM returns a public IP address instead of `10.124.1.4`:

```powershell
Resolve-DnsName -Name stonepsdev01.blob.core.windows.net
# Returns: 20.150.x.x (Public Azure IP)
```

#### Cause
1. The client VM's virtual network (`spokevnet1`) is missing a Virtual Network Link to `privatelink.blob.core.windows.net`.
2. DNS cache on the client has cached the stale public record.

#### Solution
1. Verify the VNet link in Terraform (`terraform.tfvars`):
   ```hcl
   "link2" = {
     name_suffix          = "02"
     pdz_key              = "dns_zone1"
     vnet_key             = "spokevnet1"
     registration_enabled = false
   }
   ```
2. Flush the client DNS resolver cache:
   ```powershell
   Clear-DnsClientCache
   ```

---

### Scenario 2: TCP Handshake Times Out on Port 443

#### Identification
`Test-NetConnection -ComputerName stonepsdev01.blob.core.windows.net -Port 443` fails with `TcpTestSucceeded: False`.

#### Cause
- **VNet Peering Asymmetry**: Peering is provisioned in only one direction (e.g., Hub -> Spoke, but not Spoke -> Hub).
- **NSG Blocking**: An inbound or outbound NSG rule is denying TCP 443.

#### Solution
1. Verify both peering links exist in Azure:
   ```bash
   az network vnet peering list --resource-group rg-oneps-dev-01 --vnet-name vnet-oneps-dev-spoke01 --output table
   az network vnet peering list --resource-group rg-oneps-dev-01 --vnet-name vnet-oneps-dev-hub01 --output table
   ```
   Both peering states must read **`Connected`**.
2. Verify Effective Security Rules on the VM NIC:
   ```bash
   az network nic show-effective-nsg --resource-group rg-oneps-dev-01 --name vmw-oneps-01-nic --output table
   ```

---

### Scenario 3: HTTP 403 Forbidden from Public Clients (Expected Behavior)

#### Identification
Attempting to connect to the storage account from an external workstation or non-peered network:

```bash
curl -I https://stonepsdev01.blob.core.windows.net/
# Returns: HTTP/1.1 403 This request is not authorized to perform this operation.
```

#### Explanation
This is the **intended zero-trust security behavior**. Because `public_network_access = "Disabled"`, the storage firewall denies all traffic originating outside the private endpoint.

---

## 📊 KQL Log Analytics Monitoring Queries

For production environments forwarding Storage Account diagnostic logs to Azure Log Analytics:

### 1. Monitor Private Endpoint Ingress Traffic
```kusto
StorageBlobLogs
| where TimeGenerated > ago(24h)
| where Category == "StorageRead" or Category == "StorageWrite"
| project TimeGenerated, OperationName, CallerIpAddress, StatusCode, StatusText, Uri
| order by TimeGenerated desc
```

### 2. Identify Denied Requests Blocked by Firewall
```kusto
StorageBlobLogs
| where TimeGenerated > ago(24h)
| where StatusText startswith "ClientOtherError" or StatusCode == 403
| summarize BlockedCount = count() by CallerIpAddress, StatusText, bin(TimeGenerated, 1h)
| render timechart
```
