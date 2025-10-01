# Resource Group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# AKS Cluster - Simplified for Labs
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Free tier for labs
  sku_tier = "Free"

  # Default Node Pool - Minimal for labs
  default_node_pool {
    name            = "default"
    vm_size         = "Standard_B2s"
    node_count      = 1
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"

    tags = merge(var.tags, {
      Environment = var.environment
    })
  }

  # System Assigned Identity for simplicity
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Service     = "kubernetes"
  })
}

# Additional node pools removed for simplification