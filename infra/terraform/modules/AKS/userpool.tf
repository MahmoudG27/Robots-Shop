resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  count             = var.environment == "prod" ? 1 : 0
  name              = var.user_pool_name
  vm_size           = var.user_pool_vm_size
  mode              = "User"
  zones             = ["1", "2", "3"]
  max_count         = var.user_pool_node_max_count
  min_count         = var.user_pool_node_min_count
  node_count        = var.user_pool_node_count
  max_pods          = var.user_pool_pods_node
  os_disk_size_gb   = var.user_pool_os_disk_size
  os_disk_type      = var.user_pool_os_disk_type
  os_sku            = var.user_pool_os_sku
  kubelet_disk_type = "OS"
  # orchestrator_version          = "1.27.7"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id        = var.aks_subnet_id
}