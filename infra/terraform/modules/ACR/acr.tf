# Azure Container Registry
resource "azurerm_container_registry" "private_acr" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.acr_sku
  retention_policy_in_days      = 0
  admin_enabled                 = true
  public_network_access_enabled = false
}

resource "azurerm_role_assignment" "attach_acr" {
  scope                            = azurerm_container_registry.private_acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = var.aks_kubelet_Principal_id
  skip_service_principal_aad_check = true
}