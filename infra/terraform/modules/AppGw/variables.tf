variable "resource_group_name" {}
variable "location" {}

variable "appgw_subnet" {}

variable "environment" {
  type = string
}

#################################

variable "appgw_name" {
  type    = string
  default = "AKS-AppGw"
}

variable "appgw_ip_name" {
  type = string
}