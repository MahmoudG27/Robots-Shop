terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}


provider "azurerm" {
  features {}

  subscription_id = "17f6ae62-ed0b-43a9-9a6d-dbb2ffb61b68"

  resource_provider_registrations = "none"
}