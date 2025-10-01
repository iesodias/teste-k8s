# Environment and Basic Configuration
variable "environment" {
  type        = string
  description = "Environment name (dev, hml, prod)"
  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment must be one of: dev, hml, prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "brazilsouth"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

# AKS Configuration
variable "aks_cluster_name" {
  type        = string
  description = "AKS cluster name"
}

variable "aks_dns_prefix" {
  type        = string
  description = "DNS prefix for AKS cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.31.11"
}

# Node Pool Configuration simplified

# Network Configuration removed for simplification

# Monitoring and Logs variables removed for simplification

# Helm Charts Configuration
variable "nginx_ingress_enabled" {
  type        = bool
  description = "Enable NGINX Ingress Controller"
  default     = true
}

variable "argo_rollouts_enabled" {
  type        = bool
  description = "Enable Argo Rollouts"
  default     = true
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default = {
    Project   = "AKS-CI-CD"
    ManagedBy = "Terraform"
    Owner     = "DevOps-Team"
  }
}