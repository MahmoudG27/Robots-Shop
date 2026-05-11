resource "azurerm_private_dns_zone" "mssql_private_dns_zone" {
  name                = var.mssql_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_mssql_dns" {
  name                  = "private-mssql-VnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.mssql_private_dns_zone.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group_name
}