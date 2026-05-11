# Environment Variable  =  "dev"
variable "environment" {
  type = string
}

#####################################

# Resource Group Infra
variable "resource_group_name" {
  type = string
}
variable "resource_group_location" {
  type = string
}

#####################################

# Virtual Network
variable "virtual_network_name" {
  type = string
}
variable "virtual_network_address" {
  type = string
}

#####################################

# infrastructure Subnet
variable "infra_subnet_name" {
  type = string
}
variable "infra_subnet_address" {
  type = string
}
# AKS Cluster Subnet
variable "aks_subnet_name" {
  type = string
}
variable "aks_subnet_address" {
  type = string
}

# MSSQL Server Subnet
variable "mssql_subnet_name" {
  type = string
}
variable "mssql_subnet_address" {
  type = string
}

# VPN Subnet
variable "vpn_subnet_name" {
  type = string
}
variable "vpn_subnet_address" {
  type = string
}

# Application gateway Subnet
variable "appgw_subnet_name" {
  type = string
}
variable "appgw_subnet_address" {
  type = string
}

#####################################

# Azure container registry
variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "acr_private_dns_zone_name" {
  type = string
}

variable "acr_endpoint_name" {
  type = string
}

###########################################

# Key Vault Enviroments
variable "key_vault_name" {
  type = string
}

variable "key_vault_sku" {
  type = string
}

variable "key_vault_soft_delete_retention_days" {
  type = number
}

variable "tenant_id" {
  type = string
}

variable "key_vault_endpoint_name" {
  type = string
}

variable "key_vault_private_dns_zone_name" {
  type = string
}

#####################################

# MSSQL Server
variable "mssql_name" {
  type = string
}
variable "mssql_user" {
  type = string
}
variable "mssql_version" {
  type = string
}

# MSSQL Database
variable "mssql_database_name" {
  type = string
}
variable "mssql_database_sku" {
  type = string
}
variable "mssql_database_collation" {
  type = string
}

# MSSQL Private EndPoint
variable "mssql_endpoint_name" {
  type = string
}

variable "mssql_dns_zone_name" {
  type = string
}

#####################################

# Azure DevOps Agent
variable "agent_vm_name" {
  type = string
}

variable "agent_vm_size" {
  type = string
}

variable "agent_vm_admin_username" {
  type = string
}

variable "agent_vm_computer_name" {
  type = string
}

variable "agent_vm_os_disk_type" {
  type = string
}

variable "agent_vm_os_disk_size_gb" {
  type = number
}

variable "agent_nic_name" {
  type = string
}

variable "agent_nic_private_ip" {
  type = string
}

########################################

variable "vpn_public_ip_name" {
  type = string
}

variable "vpn_gateway_name" {
  type = string
}

variable "vpn_gateway_sku" {
  type = string
}

variable "vpn_address_pool" {
  type = list(string)
}

########################################

# NAT gateway variables
variable "nat_public_ip_name" {
  type = string
}

variable "nat_gateway_name" {
  type = string
}

#####################################

# Application Gateway variables
variable "appgw_name" {
  type = string
}

variable "appgw_ip_name" {
  type = string
}

#####################################

variable "aks_version" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "aks_resources_rg" {
  type = string
}

variable "aks_sku" {
  type = string
}

# Agent Pool
variable "agent_pool_name" {
  type = string
}

variable "agent_pool_node_count" {
  type = number
}

variable "agent_pool_node_min_count" {
  type = number
}

variable "agent_pool_node_max_count" {
  type = number
}

variable "agent_pool_pods_node" {
  type = number
}

variable "agent_pool_os_sku" {
  type = string
}

variable "agent_pool_os_disk_type" {
  type = string
}

variable "agent_pool_os_disk_size" {
  type = number
}

variable "agent_pool_vm_size" {
  type = string
}


# User Pool
variable "user_pool_name" {
  type = string
}

variable "user_pool_vm_size" {
  type = string
}

variable "user_pool_node_count" {
  type = number
}

variable "user_pool_node_min_count" {
  type = number
}

variable "user_pool_node_max_count" {
  type = number
}

variable "user_pool_pods_node" {
  type = number
}

variable "user_pool_os_sku" {
  type = string
}

variable "user_pool_os_disk_type" {
  type = string
}

variable "user_pool_os_disk_size" {
  type = number
}

##########################################