# inheritance from root module
variable "resource_group_name" {}
variable "location" {}

variable "vpn_subnet_id" {}

variable "environment" {
  type = string
}

################################

# VPN Gateway Variables
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