module "ResourceGroup" {
  source                  = "../../modules/ResourceGroup"
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  environment = var.environment
}

module "Network" {
  source                  = "../../modules/Network"
  virtual_network_name    = var.virtual_network_name
  virtual_network_address = var.virtual_network_address
  infra_subnet_name       = var.infra_subnet_name
  infra_subnet_address    = var.infra_subnet_address
  aks_subnet_name         = var.aks_subnet_name
  aks_subnet_address      = var.aks_subnet_address
  mssql_subnet_name       = var.mssql_subnet_name
  mssql_subnet_address    = var.mssql_subnet_address
  vpn_subnet_name         = var.vpn_subnet_name
  vpn_subnet_address      = var.vpn_subnet_address
  appgw_subnet_name       = var.appgw_subnet_name
  appgw_subnet_address    = var.appgw_subnet_address

  environment = var.environment

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
}

module "ACR" {
  source                    = "../../modules/ACR"
  acr_name                  = var.acr_name
  acr_sku                   = var.acr_sku
  acr_endpoint_name         = var.acr_endpoint_name
  acr_private_dns_zone_name = var.acr_private_dns_zone_name

  resource_group_name      = module.ResourceGroup.resource_group_name
  location                 = module.ResourceGroup.resource_group_location
  aks_kubelet_Principal_id = module.AKS.aks_kubelet_Principal_id
  virtual_network_id       = module.Network.virtual_network_id
  infra_subnet_id          = module.Network.infra_subnet_id

  environment = var.environment
}

module "MSSQL" {
  source        = "../../modules/MSSQL"
  mssql_name    = var.mssql_name
  mssql_user    = var.mssql_user
  mssql_version = var.mssql_version

  mssql_database_name      = var.mssql_database_name
  mssql_database_collation = var.mssql_database_collation
  mssql_database_sku       = var.mssql_database_sku

  mssql_endpoint_name = var.mssql_endpoint_name
  mssql_dns_zone_name = var.mssql_dns_zone_name

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
  virtual_network_id  = module.Network.virtual_network_id
  mssql_subnet_id     = module.Network.mssql_subnet_id

  environment = var.environment
}

module "VirtualMachine" {
  source                   = "../../modules/VM"
  agent_vm_name            = var.agent_vm_name
  agent_vm_size            = var.agent_vm_size
  agent_vm_admin_username  = var.agent_vm_admin_username
  agent_vm_computer_name   = var.agent_vm_computer_name
  agent_vm_os_disk_type    = var.agent_vm_os_disk_type
  agent_vm_os_disk_size_gb = var.agent_vm_os_disk_size_gb
  agent_nic_name           = var.agent_nic_name
  agent_nic_private_ip     = var.agent_nic_private_ip

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
  infra_subnet_id     = module.Network.infra_subnet_id

  environment = var.environment
}

module "VPN" {
  source             = "../../modules/VPN"
  vpn_public_ip_name = var.vpn_public_ip_name
  vpn_gateway_name   = var.vpn_gateway_name
  vpn_gateway_sku    = var.vpn_gateway_sku
  vpn_address_pool   = var.vpn_address_pool

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
  vpn_subnet_id       = module.Network.vpn_subnet_id

  environment = var.environment
}

module "NAT" {
  source             = "../../modules/NAT"
  nat_gateway_name   = var.nat_gateway_name
  nat_public_ip_name = var.nat_public_ip_name

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
  aks_subnet_id       = module.Network.aks_subnet_id

  environment = var.environment
}

module "AppGw" {
  source        = "../../modules/AppGw"
  appgw_name    = var.appgw_name
  appgw_ip_name = var.appgw_ip_name

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
  appgw_subnet        = module.Network.appgw_subnet_id

  environment = var.environment
}

module "KeyVault" {
  source                               = "../../modules/KeyVault"
  key_vault_name                       = var.key_vault_name
  key_vault_sku                        = var.key_vault_sku
  key_vault_soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  tenant_id                            = var.tenant_id
  key_vault_endpoint_name              = var.key_vault_endpoint_name
  key_vault_private_dns_zone_name      = var.key_vault_private_dns_zone_name

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
  virtual_network_id  = module.Network.virtual_network_id
  infra_subnet_id     = module.Network.infra_subnet_id

  environment = var.environment
}

module "LAW" {
  source = "../../modules/LogAnalytics"

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location

  environment = var.environment
}

module "AKS" {
  source           = "../../modules/AKS"
  aks_name         = var.aks_name
  aks_version      = var.aks_version
  aks_sku          = var.aks_sku
  aks_resources_rg = var.aks_resources_rg

  agent_pool_name           = var.agent_pool_name
  agent_pool_node_count     = var.agent_pool_node_count
  agent_pool_node_min_count = var.agent_pool_node_min_count
  agent_pool_node_max_count = var.agent_pool_node_max_count
  agent_pool_pods_node      = var.agent_pool_pods_node
  agent_pool_os_sku         = var.agent_pool_os_sku
  agent_pool_os_disk_type   = var.agent_pool_os_disk_type
  agent_pool_os_disk_size   = var.agent_pool_os_disk_size
  agent_pool_vm_size        = var.agent_pool_vm_size

  user_pool_name           = var.user_pool_name
  user_pool_node_count     = var.user_pool_node_count
  user_pool_node_min_count = var.user_pool_node_min_count
  user_pool_node_max_count = var.user_pool_node_max_count
  user_pool_pods_node      = var.user_pool_pods_node
  user_pool_os_sku         = var.user_pool_os_sku
  user_pool_os_disk_type   = var.user_pool_os_disk_type
  user_pool_os_disk_size   = var.user_pool_os_disk_size
  user_pool_vm_size        = var.user_pool_vm_size

  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location
  aks_subnet_id       = module.Network.aks_subnet_id

  acr_id                     = module.ACR.acr_id
  appgw_id                   = module.AppGw.appgw_id
  log_analytics_workspace_id = module.LAW.log_analytics_workspace_id

  environment = var.environment

  depends_on = [module.NAT]
}

module "DNS" {
  source              = "../../modules/DNS"
  resource_group_name = module.ResourceGroup.resource_group_name
  location            = module.ResourceGroup.resource_group_location

  environment = var.environment
}