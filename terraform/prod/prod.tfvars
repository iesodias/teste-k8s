# Production Environment Configuration
environment         = "prod"
location            = "brazilsouth"
resource_group_name = "gh-devops-prd"

# AKS Cluster Configuration
aks_cluster_name   = "aks-devops-prod"
aks_dns_prefix     = "aks-devops-prod"
kubernetes_version = "1.31.11"

# Simplified configuration for basic AKS lab

# Helm Charts Configuration
nginx_ingress_enabled = true
argo_rollouts_enabled = true

# Tags
tags = {
  Project     = "AKS-CI-CD"
  Environment = "production"
  ManagedBy   = "Terraform"
  Owner       = "DevOps-Team"
  CostCenter  = "Production"
  Purpose     = "Production-Workloads"
  Criticality = "High"
  Backup      = "Required"
}