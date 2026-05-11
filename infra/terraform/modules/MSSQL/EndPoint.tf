# Create Private EndPoint For ACR
resource "azurerm_private_endpoint" "mssql_private_endpoint" {
  name                = var.mssql_endpoint_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.mssql_subnet_id

  private_service_connection {
    is_manual_connection           = false
    name                           = "mssql-endpoint-connection"
    private_connection_resource_id = azurerm_mssql_server.mssql_server.id
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name = "private-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.mssql_private_dns_zone.id
    ]
  }
}
