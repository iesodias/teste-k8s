# NGINX Ingress Controller Namespace
resource "kubernetes_namespace" "nginx_ingress" {
  count = var.nginx_ingress_enabled ? 1 : 0

  metadata {
    name = "nginx-ingress"
    labels = {
      name        = "nginx-ingress"
      environment = var.environment
    }
  }

  wait_for_default_service_account = false
}

# NGINX Ingress Controller Helm Chart
resource "helm_release" "nginx_ingress" {
  count = var.nginx_ingress_enabled ? 1 : 0

  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  namespace  = kubernetes_namespace.nginx_ingress[0].metadata[0].name

  wait          = true
  wait_for_jobs = false
  timeout       = 300

  # Basic configuration for labs
  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "90Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "256Mi"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Data source to get LoadBalancer IP
data "kubernetes_service" "nginx_ingress" {
  count = var.nginx_ingress_enabled ? 1 : 0

  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = kubernetes_namespace.nginx_ingress[0].metadata[0].name
  }

  depends_on = [helm_release.nginx_ingress]
}