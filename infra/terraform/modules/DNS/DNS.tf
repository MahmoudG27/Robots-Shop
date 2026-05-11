resource "azurerm_dns_zone" "rabbit_dns" {
  name                = "mahmoudg.net"
  resource_group_name = var.resource_group_name
}