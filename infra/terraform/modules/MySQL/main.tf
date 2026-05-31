# Create an Azure MySQL flexible server with Standby Server
resource "azurerm_mysql_flexible_server" "mysql_server" {
  name                   = var.mysql_name
  administrator_login    = var.mysql_user
  administrator_password = random_password.mysql_username_password.result
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku_name               = var.mysql_sku
  version                = var.mysql_version
  backup_retention_days = var.environment == "prod" ? 7 : 1
  zone                   = "1"
  delegated_subnet_id    = var.mysql_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_dns.id

  dynamic "high_availability" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.link_mysql_dns]
}

# Disable secure transport enforcement
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
  value               = "OFF"
}