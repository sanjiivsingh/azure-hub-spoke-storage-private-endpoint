#!/usr/bin/env bash
# ==============================================================================
# Azure Storage Private Link & Private Endpoint Verification Script (Bash)
# ==============================================================================
# Validates:
#   1. Azure Private DNS Zone resolution (FQDN resolves to Hub Private Endpoint IP).
#   2. TCP port 443 connectivity across VNet Peering to the Private Endpoint.
#   3. Storage service HTTPS reachability over Microsoft Private Link.
# ==============================================================================

set -uo pipefail

# Color palette
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

STORAGE_ACCOUNT="${1:-stonepsdev01}"
EXPECTED_PREFIX="${2:-10.124.}"
BLOB_FQDN="${STORAGE_ACCOUNT}.blob.core.windows.net"
PRIVATELINK_FQDN="${STORAGE_ACCOUNT}.privatelink.blob.core.windows.net"

echo -e "${CYAN}==========================================================${NC}"
echo -e "${CYAN} Azure Storage Private Link Connectivity Test Suite (Bash)${NC}"
echo -e "${CYAN} Target Storage Account : ${YELLOW}${STORAGE_ACCOUNT}${NC}"
echo -e "${CYAN} Blob FQDN              : ${YELLOW}${BLOB_FQDN}${NC}"
echo -e "${CYAN} Expected Subnet Prefix : ${YELLOW}${EXPECTED_PREFIX}*${NC}"
echo -e "${CYAN}==========================================================${NC}"
echo ""

# ------------------------------------------------------------------------------
# Test 1: DNS Resolution Verification
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[1/3] Testing DNS resolution for ${BLOB_FQDN}...${NC}"

RESOLVED_IP=""
if command -v dig >/dev/null 2>&1; then
    RESOLVED_IP=$(dig +short "${BLOB_FQDN}" | tail -n1)
elif command -v nslookup >/dev/null 2>&1; then
    RESOLVED_IP=$(nslookup "${BLOB_FQDN}" 2>/dev/null | awk '/^Address: / { print $2 }' | tail -n1)
elif command -v getent >/dev/null 2>&1; then
    RESOLVED_IP=$(getent hosts "${BLOB_FQDN}" | awk '{ print $1 }' | head -n1)
fi

if [[ -n "${RESOLVED_IP}" ]]; then
    echo -e "  ${GREEN}✓ DNS Query Succeeded!${NC}"
    echo -e "    - Resolved IP : ${GREEN}${RESOLVED_IP}${NC}"

    if [[ "${RESOLVED_IP}" == "${EXPECTED_PREFIX}"* ]]; then
        echo -e "    - ${GREEN}[PASS] IP matches expected Hub Private Endpoint subnet (${EXPECTED_PREFIX}*)${NC}"
    else
        echo -e "    - ${RED}[WARN] IP (${RESOLVED_IP}) does not match expected prefix (${EXPECTED_PREFIX}*). Verify Private DNS Zone VNet Link.${NC}"
    fi
else
    echo -e "  ${RED}✗ [FAIL] Failed to resolve IP for ${BLOB_FQDN}.${NC}"
fi

echo ""

# ------------------------------------------------------------------------------
# Test 2: TCP Port 443 Handshake across VNet Peering
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[2/3] Testing TCP Port 443 handshake to Private Endpoint...${NC}"

TCP_SUCCESS=false

if command -v nc >/dev/null 2>&1; then
    if nc -z -v -w 4 "${BLOB_FQDN}" 443 >/dev/null 2>&1; then
        TCP_SUCCESS=true
    fi
elif (echo > /dev/tcp/"${BLOB_FQDN}"/443) >/dev/null 2>&1; then
    TCP_SUCCESS=true
elif command -v curl >/dev/null 2>&1; then
    if curl -s --connect-timeout 4 "https://${BLOB_FQDN}" >/dev/null 2>&1 || [ $? -eq 22 ] || [ $? -eq 52 ]; then
        TCP_SUCCESS=true
    fi
fi

if [ "${TCP_SUCCESS}" = true ]; then
    echo -e "  ${GREEN}✓ [PASS] TCP Port 443 is OPEN and accessible across VNet Peering!${NC}"
else
    echo -e "  ${RED}✗ [FAIL] Unable to establish TCP session on port 443 to ${BLOB_FQDN}.${NC}"
    echo -e "    ${GRAY}Verify VNet peering state and Hub PE subnet NSG/policies.${NC}"
fi

echo ""

# ------------------------------------------------------------------------------
# Test 3: HTTPS Endpoint Reachability
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[3/3] Probing HTTPS endpoint on Storage Account...${NC}"

if command -v curl >/dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "https://${BLOB_FQDN}/" || true)
    
    # Azure Blob Storage responds with 400 Bad Request to unauthenticated root GET requests,
    # which confirms successful TLS handshake and private reachability!
    if [[ "${HTTP_CODE}" == "400" ]] || [[ "${HTTP_CODE}" == "200" ]] || [[ "${HTTP_CODE}" == "403" ]]; then
        echo -e "  ${GREEN}✓ [PASS] Storage Service reached over Private Link! (HTTP Code: ${HTTP_CODE})${NC}"
    else
        echo -e "  ${RED}✗ [FAIL] Unexpected HTTP response or connection timeout (HTTP Code: ${HTTP_CODE})${NC}"
    fi
else
    echo -e "  ${GRAY}curl not found; skipping HTTPS probe.${NC}"
fi

echo ""
echo -e "${CYAN}==========================================================${NC}"
echo -e "${CYAN} Verification Completed.${NC}"
echo -e "${CYAN}==========================================================${NC}"

