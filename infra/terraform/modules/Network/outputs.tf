# Virtual Network Outputs
output "virtual_network_name" {
  value = azurerm_virtual_network.project_vnet.name
}
output "virtual_network_id" {
  value = azurerm_virtual_network.project_vnet.id
}

# Infrastructure Subnet id
output "infra_subnet_id" {
  value = azurerm_subnet.infra_subnet.id
}

# AKS Cluster Subnet id
output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

# MSSQL Subnet id
output "mssql_subnet_id" {
  value = azurerm_subnet.mssql_subnet.id
}

# VPN Subnet id
output "vpn_subnet_id" {
  value = azurerm_subnet.vpn_subnet.id
}

# Application gateway Subnet id
output "appgw_subnet_id" {
  value = azurerm_subnet.appgw_subnet.id
}