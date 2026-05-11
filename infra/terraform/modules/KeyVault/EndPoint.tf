# Create private Endpoint for Key vault
resource "azurerm_private_endpoint" "keyvault_private_endpoint" {
  location            = var.location
  name                = var.key_vault_endpoint_name
  resource_group_name = var.resource_group_name
  subnet_id           = var.infra_subnet_id

  private_service_connection {
    is_manual_connection           = false
    name                           = "private-key-vault-endpoint"
    private_connection_resource_id = azurerm_key_vault.app_key_vault.id
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name = "private-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.keyvault_private_dns_zone.id
    ]
  }
}
