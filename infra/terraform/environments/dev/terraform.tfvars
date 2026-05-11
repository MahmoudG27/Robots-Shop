# This file contains the variables for the Azure infrastructure deployment.

# This section defines the environment var. 
environment = "dev"


# This section defines the variables for the Resource Group
resource_group_name     = "eTickets"
resource_group_location = "North Europe"


# This section defines the variables for the virtual network.
virtual_network_name    = "application-vnet"
virtual_network_address = "10.224.0.0/15"

# This section defines the variables for the subnets in the virtual network.
aks_subnet_name      = "aks-subnet"
aks_subnet_address   = "10.224.0.0/16"
infra_subnet_name    = "infra-subnet"
infra_subnet_address = "10.225.0.0/24"
mssql_subnet_name    = "mssql-subnet"
mssql_subnet_address = "10.225.2.0/24"
vpn_subnet_name      = "GatewaySubnet"
vpn_subnet_address   = "10.225.3.0/24"
appgw_subnet_name    = "appgw-subnet"
appgw_subnet_address = "10.225.4.0/24"

# This section defines the variables for the Application Gateway.
appgw_name    = "aks-appgw"
appgw_ip_name = "pip-appgw"

# This section defines the variables for the Azure Container Registry (ACR).
acr_name                  = "mgcontainerregistryetickets" # Must be globally unique
acr_sku                   = "Premium"                     # Options: Basic, Standard, Premium
acr_private_dns_zone_name = "privatelink.azurecr.io"
acr_endpoint_name         = "acr-endpoint"

# This section defines the variables for the MSSQL server.
mssql_name               = "eticketdbserver"              # Must be globally unique
mssql_user               = "mahmoud"                      # Admin username
mssql_version            = "12.0"                         # MSSQL database version
mssql_database_name      = "eticket-db"                   # Name of the database
mssql_database_collation = "SQL_Latin1_General_CP1_CI_AS" # Database collation
mssql_database_sku       = "S0"                           # Data base SKU
mssql_endpoint_name      = "mssql-endpoint"
mssql_dns_zone_name      = "privatelink.database.windows.net" # DNS zone for private link

# This section defines the variables for the Virtual Machine.
agent_vm_name            = "agent-vm"        # Name of the VM
agent_vm_size            = "Standard_D2s_v3" # VM compute size
agent_vm_admin_username  = "mahmoud"         # Admin username
agent_vm_computer_name   = "self-hosted-azure-devops-agent"
agent_vm_os_disk_type    = "Standard_LRS" # Disk type - Premium_LRS, Standard_LRS, StandardSSD_LRS
agent_vm_os_disk_size_gb = 30             # OS Disk size in GB
agent_nic_name           = "agent-nic"
agent_nic_private_ip     = "10.225.0.70" # Static private IP for the VM

# This section defines the variables for VPN (Point-to-Site)
vpn_public_ip_name = "vpn-gateway-pip"
vpn_gateway_name   = "vpn-gateway"
vpn_gateway_sku    = "VpnGw2AZ"
vpn_address_pool   = ["172.16.0.0/24"] # static IP pool for VPN clients

# This section defines the variables for the NAT gateway.
nat_public_ip_name = "pip-nat-gateway"
nat_gateway_name   = "aks-nat-gateway"

# This section defines the variables for the Key Vault.
key_vault_name                       = "mahmoudgeTickets" # The name must be globally unique
key_vault_sku                        = "standard"         # standard and premium
key_vault_soft_delete_retention_days = 7                  # This value can be between 7 and 90 (the default) days.
tenant_id                            = "e12a260c-947a-40e3-a826-aa800e3bcc10"
key_vault_endpoint_name              = "key-vault-endpoint"
key_vault_private_dns_zone_name      = "privatelink.vaultcore.azure.net"

# This section defines the variables for the AKS cluster.
aks_name         = "micro-aks-cluster" # Name of the AKS cluster
aks_version      = "1.33.5"            # Kubernetes version
aks_resources_rg = "micro-aks-rg"      # Resource group for AKS resources
aks_sku          = "Standard"          # AKS SKU (Free/Basic/Standard)

agent_pool_name           = "agentpool"       # Name of the agent pool
agent_pool_vm_size        = "Standard_D2s_v3" # VM size for the agent nodes
agent_pool_node_count     = 2                 # Initial number of nodes
agent_pool_node_min_count = 1                 # Minimum number of nodes for autoscaling
agent_pool_node_max_count = 3                 # Maximum number of nodes for autoscaling
agent_pool_os_sku         = "Ubuntu"          # OS SKU for the agent nodes
agent_pool_os_disk_type   = "Ephemeral"       # OS Disk type for the agent nodes
agent_pool_os_disk_size   = 30                # OS Disk size in GB for the agent nodes
agent_pool_pods_node      = 110               # Maximum number of pods per node

user_pool_name           = "userpool"        # Name of the user pool
user_pool_vm_size        = "Standard_D4s_v3" # VM size for the user nodes
user_pool_node_count     = 2                 # Initial number of nodes
user_pool_node_min_count = 1                 # Minimum number of nodes for autoscaling
user_pool_node_max_count = 3                 # Maximum number of nodes for autoscaling
user_pool_os_sku         = "Ubuntu"          # OS SKU for the user nodes
user_pool_os_disk_type   = "Ephemeral"       # OS Disk type for the user nodes
user_pool_os_disk_size   = 30                # OS Disk size in GB for the user nodes
user_pool_pods_node      = 110               # Maximum number of pods per node
####################################################################################################