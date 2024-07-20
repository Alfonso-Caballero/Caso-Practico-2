# Creación del cluster de Azure Kubernetes Service (AKS)
# Recurso: Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name # Nombre del AKS cluster
  location            = azurerm_resource_group.example.location # Ubicación del AKS
  resource_group_name = azurerm_resource_group.example.name # Grupo de recursos al que pertenece
  dns_prefix          = var.aks_name # Prefijo DNS del AKS
  kubernetes_version  = "1.28.10" # Versión de Kubernetes

# Configuración del grupo de nodos predeterminado para el cluster de AKS
  default_node_pool {
    name            = "default" # Nombre del grupo de nodos 
    node_count      = var.aks_node_count # Número de nodos en el grupo
    vm_size         = var.aks_node_vm_size # Tamaño de la máquina virtual
    os_disk_size_gb = 30 # Tamaño del disco del sistema operativo en GB para cada nodo
  }

# Configuración de la indentidad del cluster AKS
  identity {
    type = "SystemAssigned" # Tipo de identidad asignada por el sistema
  }

# Configuración del perfil de red del cluster AKS
  network_profile {
    network_plugin = "azure" # Plugin de red a utilizar
  }

  tags = {
    Environment = "Production" # Etiqueta para el entorno
  }
}

# Asignación de roles para permitir que AKS extraiga imágenes de ACR
# Asignar permisos ACR al AKS
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                   = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id # ID del principal del kubelet de AKS
  role_definition_name           = "AcrPull" # Nombre de la definición del rol, en este caso "AcrPull" para permitir la extracción de imágenes de ACR
  scope                          = azurerm_container_registry.acr.id # Alcance del rol, en este caso el ID del registro de contenedores (ACR)
}
