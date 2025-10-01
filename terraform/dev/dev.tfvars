# Development Environment Configuration
environment         = "dev"
location            = "brazilsouth"
resource_group_name = "gh-devops-dev"

# AKS Cluster Configuration
aks_cluster_name   = "aks-devops-dev"
aks_dns_prefix     = "aks-devops-dev"
kubernetes_version = "1.31.11"

# Simplified configuration for basic AKS lab

# Helm Charts Configuration
nginx_ingress_enabled = true
argo_rollouts_enabled = true

# Tags
tags = {
  Project     = "AKS-CI-CD"
  Environment = "development"
  ManagedBy   = "Terraform"
  Owner       = "DevOps-Team"
  CostCenter  = "Development"
  Purpose     = "Development-Testing"
}