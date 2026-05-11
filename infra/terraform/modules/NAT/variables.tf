# inheritance from root module
variable "resource_group_name" {}
variable "location" {}

variable "aks_subnet_id" {} # NAT Gateway must associated with the AKS Subnet.

variable "environment" {
  type = string
}

################################

# NAT gateway variables
variable "nat_gateway_name" {
  type = string
}

variable "nat_public_ip_name" {
  type = string
}