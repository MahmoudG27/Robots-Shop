# Flexbile MySQL Server id
output "mysql_id" {
  value = azurerm_mysql_flexible_server.mysql_server.id
}

output "mysql_fqdn" {
  description = "Private DNS name of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql_server.fqdn
}

output "mysql_username_password" {
  value       = random_password.mysql_username_password.result
  sensitive   = true
  description = "MySQL admin password (sensitive)"
}