# Agent VM admin password
output "agent_vm_admin_username_password" {
  value       = random_password.agent_password.result
  sensitive   = true
  description = "Agent VM admin password (sensitive)"
}
