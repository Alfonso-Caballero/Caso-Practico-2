# Definición de variables para ser utilizadas en los archivos de configuración de Terraform

# Nombre del grupo de recursos donde se desplegarán los recursos de Azure
variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "myResourceGroup"
}

# Ubicación donde se desplegarán los recursos
variable "location" {
  description = "Ubicación de los recursos"
  type        = string
  default     = "eastus"
}

# Nombre del Azure Container Registry
variable "acr_name" {
  description = "Nombre del Azure Container Registry"
  type        = string
  default     = "myAcrRegistryAlfonso"
}

# Nombre de la máquina virtual
variable "vm_name" {
  description = "Nombre de la máquina virtual"
  type        = string
  default     = "my_VM"
}

# Tamaño de la máquina virtual
variable "vm_size" {
  description = "Tamaño de la máquina virtual"
  type        = string
  default     = "Standard_DC1s_v2"
}

# Nombre del AKS cluster
variable "aks_name" {
  description = "Nombre del AKS cluster"
  type        = string
  default     = "myAksCluster"
}

# Número de nodos del AKS cluster
variable "aks_node_count" {
  description = "Número de nodos del AKS cluster"
  type        = number
  default     = 1
}

# Tamaño de las VM de los nodos del AKS cluster
variable "aks_node_vm_size" {
  description = "Tamaño de las VM de los nodos del AKS cluster"
  type        = string
  default     = "Standard_b8pls_v2"
}