resource "azurerm_mssql_server" "mssql_server" {
  name                         = var.mssql_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.mssql_version
  administrator_login          = var.mssql_user
  administrator_login_password = random_password.mssql_username_password.result
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "dbname" {
  name        = var.mssql_database_name
  server_id   = azurerm_mssql_server.mssql_server.id
  collation   = var.mssql_database_collation
  sku_name    = var.mssql_database_sku
  max_size_gb = 20
}