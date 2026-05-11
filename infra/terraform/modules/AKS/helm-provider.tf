# # This File is used to deploy NGINX Ingress Controller using Helm in AKS Cluster
# # Create an internal load balancer with a specific IP and a private link service (PLS)
# # Configure the NGINX Ingress Controller to use the internal load balancer


# # Configure Helm to talk to your AKS cluster
# provider "helm" {
#   kubernetes {
#     host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
#     client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
#     client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
#     cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
#   }
# }

# resource "local_file" "kubeconfig" {
#   content  = azurerm_kubernetes_cluster.aks.kube_config_raw
#   filename = "${path.module}/kubeconfig"

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }

# # # Run this resource when run the terrafrom from Linux
# # # Set the KUBECONFIG environment variable using Linux
# # resource "null_resource" "wait_for_nodes" {
# #   provisioner "local-exec" {
# #     command = <<EOT
# #       export KUBECONFIG=${path.root}/kubeconfig
# #       echo "Waiting for all AKS nodes to be Ready..."
# #       kubectl wait --for=condition=Ready nodes --all --timeout=600s
# #     EOT
# #   }
# #   depends_on = [local_file.kubeconfig]
# # }

# ## Run this resource when run the terrafrom from Windows PowerShell
# # Set the KUBECONFIG environment variable using Windows PowerShell
# resource "null_resource" "wait_for_nodes" {
#   provisioner "local-exec" {
#     interpreter = ["PowerShell", "-Command"]
#     command = @"
#       filename = "${path.root}/kubeconfig"
#       Write-Output "Waiting for all AKS nodes to be Ready..."
#       kubectl wait --for=condition=Ready nodes --all --timeout=600s
#     "@
#   }
#   depends_on = [local_file.kubeconfig]
# }


# # Install ingress-nginx with Helm
# resource "helm_release" "nginx_ingress" {
#   name             = "ingress-nginx"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   namespace        = "ingress-nginx"
#   create_namespace = true

#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
#     value = "true"
#   }
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal-subnet"
#     value = "aks"
#   }
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-pls-create"
#     value = "true"
#   }
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-pls-visibility"
#     value = "*"
#   }
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-pls-auto-approval"
#     value = "3f4307f4-ae2b-4a54-a328-4564262560d1"
#   }
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-pls-ip-configuration-ip-address"
#     value = "10.225.0.60"
#   }
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-pls-ip-configuration-ip-address-count"
#     value = "1"
#   }
#   set {
#     name  = "controller.service.loadBalancerIP"
#     value = "10.225.0.50"
#   }

#   depends_on = [null_resource.wait_for_nodes]
# }