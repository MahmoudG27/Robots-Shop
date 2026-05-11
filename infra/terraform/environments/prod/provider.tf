terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}


provider "azurerm" {
  features {}

  subscription_id = "17f6ae62-ed0b-43a9-9a6d-dbb2ffb61b68"

  resource_provider_registrations = "none"
}