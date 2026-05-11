variable "resource_group_name" {}
variable "location" {}

variable "virtual_network_id" {}
variable "mssql_subnet_id" {}

variable "environment" {
  type = string
}

################################

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