resource "azurerm_user_assigned_identity" "github_runner" {
  name                = "github-runner-mi"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = var.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github_runner.principal_id
}
