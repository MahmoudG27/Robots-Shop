variable "resource_group_name" {}
variable "location" {}

variable "virtual_network_id" {}
variable "mysql_subnet_id" {}

variable "environment" {
  type = string
}

################################

# Flexible MySQL Server
variable "mysql_name" {
  type    = string
  default = "rabbit-mysql-data"
}
variable "mysql_user" {
  type    = string
  default = "mahmoud"
}
variable "mysql_version" {
  type    = string
  default = "8.0.21"
}
variable "mysql_sku" {
  type    = string
  default = "GP_Standard_D2ads_v5"
}

# Replica MySQL Server
variable "mysql_replica_name" {
  type    = string
  default = "rabbit-mysql-data-replica"
}

variable "mysql_dns_zone_name" {
  type = string
}