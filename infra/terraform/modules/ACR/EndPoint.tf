# Create Private EndPoint For ACR
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                          = var.acr_endpoint_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.infra_subnet_id
  custom_network_interface_name = "ACR-EndPoint-NIC"

  private_service_connection {
    is_manual_connection           = false
    name                           = "acr-endpoint-connection"
    private_connection_resource_id = azurerm_container_registry.private_acr.id
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name = "private-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr_private_dns_zone.id
    ]
  }
}
