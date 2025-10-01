# Argo Rollouts Namespace
resource "kubernetes_namespace" "argo_rollouts" {
  count = var.argo_rollouts_enabled ? 1 : 0

  metadata {
    name = "argo-rollouts"
    labels = {
      name        = "argo-rollouts"
      environment = var.environment
    }
  }

  wait_for_default_service_account = false
}

# Argo Rollouts Helm Chart
resource "helm_release" "argo_rollouts" {
  count = var.argo_rollouts_enabled ? 1 : 0

  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = "2.32.4"
  namespace  = kubernetes_namespace.argo_rollouts[0].metadata[0].name

  wait          = true
  wait_for_jobs = false
  timeout       = 300

  # Basic configuration for labs
  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "256Mi"
  }

  set {
    name  = "dashboard.enabled"
    value = "true"
  }

  set {
    name  = "dashboard.service.type"
    value = "ClusterIP"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Sample App Namespace
resource "kubernetes_namespace" "sample_app" {
  count = var.argo_rollouts_enabled ? 1 : 0

  metadata {
    name = "sample-app"
    labels = {
      name        = "sample-app"
      environment = var.environment
    }
  }

  wait_for_default_service_account = false
}