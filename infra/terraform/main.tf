terraform {
  required_version = ">= 1.7.0"
}

locals {
  environments = {
    dev  = "./environments/dev"
    prod = "./environments/prod"
  }
}

output "available_environments" {
  description = "List of environments with their Terraform paths."
  value       = local.environments
}