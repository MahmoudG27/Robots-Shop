variable "resource_group_name" {}
variable "location" {}

variable "aks_subnet_id" {}

variable "acr_id" {}
variable "appgw_id" {}
variable "log_analytics_workspace_id" {}

variable "environment" {
  type = string
}

################################

############################### AKS Variables ###############################

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

###########################################

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