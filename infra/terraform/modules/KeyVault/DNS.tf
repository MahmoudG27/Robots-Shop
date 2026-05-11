# Create private dns zone for key vault private endpoint
resource "azurerm_private_dns_zone" "keyvault_private_dns_zone" {
  name                = var.key_vault_private_dns_zone_name
  resource_group_name = var.resource_group_name
}

# Create azure private dns zone virtual network link for key vault private endpoint vnet
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_private_dns_zone_virtual_network_link" {
  name                  = "private-dns-zone-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_private_dns_zone.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.virtual_network_id
}