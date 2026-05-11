resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks"

  azure_policy_enabled              = true
  local_account_disabled            = false
  support_plan                      = "KubernetesOfficial"
  kubernetes_version                = var.aks_version
  node_resource_group               = var.aks_resources_rg
  private_cluster_enabled           = true     # Set to true to enable private cluster
  private_dns_zone_id               = "System" # Set to "System" to enable private cluster with private DNS zone
  role_based_access_control_enabled = true
  sku_tier                          = var.aks_sku

  automatic_upgrade_channel           = "patch"
  node_os_upgrade_channel             = "NodeImage"
  private_cluster_public_fqdn_enabled = true
  oidc_issuer_enabled                 = true
  workload_identity_enabled           = true

  identity {
    type = "SystemAssigned"
  }

  # identity {
  #   type         = "UserAssigned"
  #   identity_ids = [var.aks_cluster_identity_id]
  # }

  # # 🔑 Use your custom identity for kubelet
  # kubelet_identity {
  #   client_id                 = var.aks_node_identity_client_id
  #   object_id                 = var.aks_node_identity_principal_id
  #   user_assigned_identity_id = var.aks_node_identity_id
  # }

  default_node_pool {
    name                         = var.agent_pool_name
    fips_enabled                 = false
    kubelet_disk_type            = "OS"
    max_count                    = var.agent_pool_node_max_count
    min_count                    = var.agent_pool_node_min_count
    node_count                   = var.agent_pool_node_count
    max_pods                     = var.agent_pool_pods_node
    only_critical_addons_enabled = true
    os_disk_size_gb              = var.agent_pool_os_disk_size
    os_disk_type                 = var.agent_pool_os_disk_type
    os_sku                       = var.agent_pool_os_sku
    scale_down_mode              = "Delete"
    type                         = "VirtualMachineScaleSets"
    ultra_ssd_enabled            = false
    vm_size                      = var.agent_pool_vm_size
    zones                        = null # [1, 2, 3]
    vnet_subnet_id               = var.aks_subnet_id
    auto_scaling_enabled         = true
  }

  network_profile {
    dns_service_ip      = "10.0.0.10"
    ip_versions         = ["IPv4"]
    load_balancer_sku   = "standard"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    outbound_type       = "userAssignedNATGateway"
    service_cidr        = "10.0.0.0/16"
    service_cidrs       = ["10.0.0.0/16"]
  }

  ingress_application_gateway {
    gateway_id = var.appgw_id
    # gateway_name = "myApplicationGateway"
    # subnet_cidr  = "10.225.4.0/24"
    # subnet_id    = null
    # Can define "gateway_name" or "subnet_cidr" "subnet_id" when need AKS create the Application gateway
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    day_of_week = "Sunday"
    start_time  = "00:00"
    duration    = 8
    utc_offset  = "+00:00"
    interval    = 1
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    day_of_week = "Sunday"
    start_time  = "00:00"
    duration    = 8
    utc_offset  = "+00:00"
    interval    = 1
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  # key_vault_secrets_provider {
  #   secret_identity          = [
  #     {
  #       client_id                 = ""
  #       object_id                 = ""
  #       user_assigned_identity_id = ""
  #     },
  #   ]
  #   secret_rotation_enabled  = false
  #   secret_rotation_interval = "2m"
  # }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "AKS"
  }
}
