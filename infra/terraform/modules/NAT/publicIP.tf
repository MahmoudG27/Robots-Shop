resource "azurerm_public_ip" "pip_nat_gateway" {
  name                = var.nat_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard" # "StandardV2"
  sku_tier            = "Regional"
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_pip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.pip_nat_gateway.id
}