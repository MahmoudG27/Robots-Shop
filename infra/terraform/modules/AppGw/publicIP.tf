resource "azurerm_public_ip" "pip_appgw" {
  name                = var.appgw_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
  sku_tier            = "Regional"
}