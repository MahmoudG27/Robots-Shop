resource "azurerm_virtual_network" "project_vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.virtual_network_address]
}