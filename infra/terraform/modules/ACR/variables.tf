variable "resource_group_name" {}
variable "location" {}

variable "aks_kubelet_Principal_id" {}
variable "infra_subnet_id" {}
variable "virtual_network_id" {}

variable "environment" {
  type = string
}

################################

# ACR Enviroments
variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
}

################################

# ACR DNS 
variable "acr_private_dns_zone_name" {
  type    = string
  default = "privatelink.azurecr.io"
}

# ACR EndPoint
variable "acr_endpoint_name" {
  type    = string
  default = "ACR-EndPoint"
}

# variable "EndPoint_acr_private_ip" {
#   type    = string
#   default = "10.225.0.110"
# }
# variable "EndPoint_acr_data_private_ip" {
#   type    = string
#   default = "10.225.0.111"
# }