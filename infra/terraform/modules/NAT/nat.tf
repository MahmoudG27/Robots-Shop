resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  idle_timeout_in_minutes = 10
  sku_name                = "Standard" #"StandardV2"
  #  zones                   = ["1", "2", "3"]
}

resource "azurerm_subnet_nat_gateway_association" "association" {
  subnet_id      = var.aks_subnet_id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}