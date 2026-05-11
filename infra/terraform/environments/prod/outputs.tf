# output "mysql_username_password" {
#   value       = module.MySQL.mysql_username_password
#   sensitive   = true
#   description = "MySQL user password (sensitive)"
# }

output "mssql_username_password" {
  value       = module.MSSQL.mssql_username_password
  sensitive   = true
  description = "MySQL user password (sensitive)"
}

output "agent_vm_admin_username_password" {
  value       = module.VirtualMachine.agent_vm_admin_username_password
  sensitive   = true
  description = "Agent VM admin password (sensitive)"
}