# Homologation Environment Configuration
environment         = "hml"
location            = "brazilsouth"
resource_group_name = "gh-devops-hml"

# AKS Cluster Configuration
aks_cluster_name   = "aks-devops-hml"
aks_dns_prefix     = "aks-devops-hml"
kubernetes_version = "1.31.11"

# Simplified configuration for basic AKS lab

# Helm Charts Configuration
nginx_ingress_enabled = true
argo_rollouts_enabled = true

# Tags
tags = {
  Project     = "AKS-CI-CD"
  Environment = "homologation"
  ManagedBy   = "Terraform"
  Owner       = "DevOps-Team"
  CostCenter  = "QA"
  Purpose     = "Integration-Testing"
}