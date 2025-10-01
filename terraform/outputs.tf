# AKS Cluster Outputs
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_cluster_endpoint" {
  description = "Endpoint for the AKS cluster API server"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "aks_cluster_ca_certificate" {
  description = "Base64 encoded CA certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "aks_cluster_client_certificate" {
  description = "Base64 encoded client certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}

output "aks_cluster_client_key" {
  description = "Base64 encoded client key for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}

# Kube Config
output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = data.azurerm_resource_group.main.location
}

# Network outputs removed for simplification

# Identity outputs removed for simplification

# Node Pool Information simplified
output "default_node_pool_name" {
  description = "Name of the default node pool"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = var.kubernetes_version
}

# Network Security Group outputs removed for simplification