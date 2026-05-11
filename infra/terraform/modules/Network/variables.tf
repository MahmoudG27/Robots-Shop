# inheritance from root module
variable "resource_group_name" {}
variable "location" {}

variable "environment" {
  type = string
}

################################

# Virtual Network
variable "virtual_network_name" {
  type = string
}
variable "virtual_network_address" {
  type = string
}
########################################

# infrastructure Subnet for resources like VM, ACR, Key Vault, etc.
variable "infra_subnet_name" {
  type = string
}
variable "infra_subnet_address" {
  type = string
}

# AKS Cluster Subnet & NAT Gateway
variable "aks_subnet_name" {
  type = string
}
variable "aks_subnet_address" {
  type = string
}

# MSSQL Subnet
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