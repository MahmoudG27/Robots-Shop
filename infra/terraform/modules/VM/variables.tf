# inheritance from root module
variable "resource_group_name" {}
variable "location" {}

variable "infra_subnet_id" {}

variable "environment" {
  type = string
}

################################

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

################################

# Network Interface
variable "agent_nic_name" {
  type = string
}

variable "agent_nic_private_ip" {
  type = string
}