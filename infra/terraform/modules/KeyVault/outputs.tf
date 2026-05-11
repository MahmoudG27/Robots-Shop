# Azure Container Registry id
output "keyvault_id" {
  value = azurerm_key_vault.app_key_vault.id
}