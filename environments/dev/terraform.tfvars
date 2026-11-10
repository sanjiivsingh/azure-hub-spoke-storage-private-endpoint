environment = "dev"
project     = "oneps"
location    = "central india"

# Tags
tags = {
  managedby = "terraform"
  team      = "infra-devops"
}

# Resource group configuration
resource_group_config = {
  rg1 = {
    name_suffix = "01"
  }
}

# Storage account configuration
storage_account_config = {
  "storage_account1" = {
    name_suffix                     = "01"
    rg_key                          = "rg1"
    public_network_access           = "Disabled"
    allow_nested_items_to_be_public = false
  }
}

# Blob Container configuration
container_config = {
  "container1" = {
    name_suffix           = "01"
    st_key                = "storage_account1"
    container_access_type = "private"
  }
}

# Virtual Network Configuration
virtual_network_config = {
  "hubvnet1" = {
    name_suffix   = "hub01"
    rg_key        = "rg1"
    address_space = ["10.124.0.0/16"]
  }

  "spokevnet1" = {
    name_suffix   = "spoke01"
    rg_key        = "rg1"
    address_space = ["10.125.0.0/16"]
  }
}

# Virtual Network Peering Configuration
vnet_peering_config = {
  "hub-to-spoke" = {
    name_suffix     = "hub-to-spoke"
    rg_key          = "rg1"
    vnet_key        = "hubvnet1"
    remote_vnet_key = "spokevnet1"
  }
  "spoke-to-hub" = {
    name_suffix     = "spoke-to-hub"
    rg_key          = "rg1"
    vnet_key        = "spokevnet1"
    remote_vnet_key = "hubvnet1"
  }
}

# Subnet Configuration
subnet_config = {
  "pesubnet1" = {
    name_suffix                       = "pe01"
    vnet_key                          = "hubvnet1"
    subnet_num                        = 1
    subnet_prefix                     = 24
    private_endpoint_network_policies = "Disabled"
  }

  "appsubnet1" = {
    name_suffix   = "app01"
    vnet_key      = "spokevnet1"
    subnet_num    = 1
    subnet_prefix = 24
  }

  "dbsubnet1" = {
    name_suffix   = "db01"
    vnet_key      = "spokevnet1"
    subnet_num    = 2
    subnet_prefix = 24
  }
}

# Private DNS Zone Configuration
private_dns_zone_config = {
  dns_zone1 = {
    name   = "privatelink.blob.core.windows.net"
    rg_key = "rg1"
  }
}

# Private DNS Zone Virtual Network Link Configuration
private_dns_zone_vnet_link_config = {
  "link1" = {
    name_suffix          = "01"
    pdz_key              = "dns_zone1"
    vnet_key             = "hubvnet1"
    registration_enabled = true
  }
  "link2" = {
    name_suffix          = "02"
    pdz_key              = "dns_zone1"
    vnet_key             = "spokevnet1"
    registration_enabled = false
  }
}

# Private Endpoint Configuration
private_endpoint_config = {
  "pe1" = {
    name_suffix                                  = "01"
    rg_key                                       = "rg1"
    st_key                                       = "storage_account1"
    subnet_key                                   = "pesubnet1"
    is_manual_connection                         = false
    pdz_key                                      = "dns_zone1"
    private_service_connection_name              = "psc1"
    private_service_connection_subresource_names = ["blob"]
    private_dns_zone_group_name                  = "pdzgroup1"

  }
}

# Virtual Machine Configuration
virtual_machine_windows_config = {
  "vm1" = {
    vm_name_suffix    = "01"
    vm_size           = "Standard_D4_v5"
    rg_key            = "rg1"
    subnet_key        = "appsubnet1"
    public_ip_enabled = true
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

# Fetch Key Vault Details and Secrets
key_vault_details = {
  key_vault_name      = "onepskv"
  resource_group_name = "rg-oneps-keyvault"
  secrets = {
    "vm_username" = "vm-username"
    "vm_password" = "vm-password"
  }

}
