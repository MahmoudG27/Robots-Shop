# Azure Container Registry id
output "acr_id" {
  value = azurerm_container_registry.private_acr.id
}

output "acr_login_server" {
  value = azurerm_container_registry.private_acr.login_server
}