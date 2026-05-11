variable "resource_group_name" {}
variable "location" {}

variable "infra_subnet_id" {}
variable "virtual_network_id" {}

variable "environment" {
  type = string
}

################################

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

################################

# Key Vault EndPoint Variables
variable "key_vault_endpoint_name" {
  type = string
}

################################

# Key Vault DNS Zone Variables
variable "key_vault_private_dns_zone_name" {
  type = string
}