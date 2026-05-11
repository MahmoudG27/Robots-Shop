# MSSQL Server id
output "mssql_id" {
  value = azurerm_mssql_server.mssql_server.id
}

output "mssql_username_password" {
  value       = random_password.mssql_username_password.result
  sensitive   = true
  description = "MSSQL admin password (sensitive)"
}