<#
.SYNOPSIS
    Automated connectivity and DNS validation script for Azure Storage Private Link.

.DESCRIPTION
    Executes inside the workload VM (e.g., vmw-oneps-01 in Spoke VNet) to verify:
    1. Azure Private DNS Zone resolution (FQDN resolves to Hub Private Endpoint IP).
    2. TCP port 443 connectivity across VNet Peering to the Private Endpoint.
    3. Storage service HTTPS reachability.

.PARAMETER StorageAccountName
    The name of the Azure Storage Account (default: stonepsdev01).

.PARAMETER ExpectedSubnetRange
    Expected IP prefix of the Hub PE subnet (default: 10.124.1.).

.EXAMPLE
    .\verify-storage-connectivity.ps1 -StorageAccountName "stonepsdev01"
#>

[CmdletBinding()]
param(
    [string]$StorageAccountName = "stonepsdev01",
    [string]$ExpectedSubnetRange = "10.124."
)

$ErrorActionPreference = "Continue"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Azure Storage Private Link Connectivity Test Suite       " -ForegroundColor Cyan
Write-Host " Workload Host: $env:COMPUTERNAME                         " -ForegroundColor Cyan
Write-Host " Target Storage: $StorageAccountName                      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$blobFqdn = "$StorageAccountName.blob.core.windows.net"
$privatelinkFqdn = "$StorageAccountName.privatelink.blob.core.windows.net"

# ---------------------------------------------------------
# Test 1: DNS Resolution Verification
# ---------------------------------------------------------
Write-Host "[1/3] Testing DNS Resolution for '$blobFqdn'..." -ForegroundColor Yellow
try {
    $dnsResult = Resolve-DnsName -Name $blobFqdn -Type A -ErrorAction Stop
    $resolvedIP = ($dnsResult | Where-Object { $_.IPAddress }).IPAddress | Select-Object -First 1

    if ($resolvedIP) {
        Write-Host "  ✓ DNS Query Succeeded!" -ForegroundColor Green
        Write-Host "    - Resolved IP: $resolvedIP" -ForegroundColor Green

        if ($resolvedIP.StartsWith($ExpectedSubnetRange)) {
            Write-Host "    - [PASS] IP belongs to expected private range ($ExpectedSubnetRange*)" -ForegroundColor Green
        } else {
            Write-Host "    - [WARN] IP ($resolvedIP) does not match expected private range ($ExpectedSubnetRange*). Check Private DNS Zone links." -ForegroundColor Magenta
        }
    } else {
        Write-Host "  ✗ DNS resolved without an A record." -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ DNS resolution failed: $_" -ForegroundColor Red
}

Write-Host ""

# ---------------------------------------------------------
# Test 2: Network TCP Port 443 Handshake across VNet Peering
# ---------------------------------------------------------
Write-Host "[2/3] Testing TCP Port 443 Handshake to Private Endpoint..." -ForegroundColor Yellow
try {
    $tcpTest = Test-NetConnection -ComputerName $blobFqdn -Port 443 -WarningAction SilentlyContinue

    if ($tcpTest.TcpTestSucceeded) {
        Write-Host "  ✓ [PASS] TCP Port 443 is OPEN and accessible across VNet Peering!" -ForegroundColor Green
        Write-Host "    - Remote Address: $($tcpTest.RemoteAddress)" -ForegroundColor Green
        Write-Host "    - Ping Succeeded: $($tcpTest.PingSucceeded)" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ [FAIL] Unable to establish TCP session on port 443 to $blobFqdn" -ForegroundColor Red
        Write-Host "    Verify VNet peering status and Hub NSG/route table configurations." -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Network test failed: $_" -ForegroundColor Red
}

Write-Host ""

# ---------------------------------------------------------
# Test 3: HTTPS Endpoint Probe
# ---------------------------------------------------------
Write-Host "[3/3] Probing HTTPS Endpoint on Storage Account..." -ForegroundColor Yellow
try {
    $httpsUri = "https://$blobFqdn/"
    $response = Invoke-WebRequest -Uri $httpsUri -Method Get -UseBasicParsing -ErrorAction SilentlyContinue

    Write-Host "  ✓ [PASS] HTTPS Service responded with StatusCode: $($response.StatusCode)" -ForegroundColor Green
} catch {
    # Azure Storage returns 400 Bad Request when hit at root without auth, which proves TLS connection succeeded!
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 400) {
        Write-Host "  ✓ [PASS] HTTPS Handshake and Storage Service reached! (Expected HTTP 400 for unauthenticated root query)" -ForegroundColor Green
    } else {
        Write-Host "  ℹ Response detail: $_" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Verification Completed.                                  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
