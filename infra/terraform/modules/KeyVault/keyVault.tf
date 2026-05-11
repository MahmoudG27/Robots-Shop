resource "azurerm_key_vault" "app_key_vault" {
  location                        = var.location
  name                            = var.key_vault_name
  resource_group_name             = var.resource_group_name
  sku_name                        = var.key_vault_sku
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  tenant_id                       = var.tenant_id
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  public_network_access_enabled   = false
  purge_protection_enabled        = false
  rbac_authorization_enabled      = true
  access_policy                   = []
}