resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-for-aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}