# Configuración del proveedor de Azure
provider "azurerm" {
  features {}
  subscription_id = "ac9db688-a78d-4131-bcf9-1fbec13edb70"
}

# Creación del grupo de recursos
# Recurso: Grupo de recursos
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name # Nombre del grupo de recursos
  location = var.location # Ubicación del grupo de recursos
}

# Creación del Azure Container Registry (ACR)
# Recurso: Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name # Nombre del ACR
  resource_group_name      = azurerm_resource_group.example.name # Grupo de recursos al que pertenece 
  location                 = azurerm_resource_group.example.location # Ubicación del ACR
  sku                      = "Standard" # SKU del ACR
  admin_enabled            = true  # Habilitando autenticación de administrador
}

# Creación de la máquina virtual (VM)
# Recurso: Máquina Virtual (VM)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name # Nombre de la máquina virtual
  resource_group_name = azurerm_resource_group.example.name # Grupo de recursos al que pertenece
  location            = azurerm_resource_group.example.location # Ubicación de la máquina virtual
  size                = var.vm_size # Tamaño de la VM
  admin_username      = "azureuser" # Nombre de usuario del administrador
  disable_password_authentication = true # Deshabilitar autenticación por contraseña

# Configuración de la clave SSH para el usuario admnistrador
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/alfcabal/.ssh/id_rsa.pub")  # Ruta clave SSH pública
  }

# Configuración del disco del SO
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

# Referencia a la imagen del SO
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"
  }

# Identificador de la interfaz de red
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
}

# Configuración de la interfaz de red (Network Interface)
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic" # Nombre de la interfaz de red, basado en el nombre de la VM
  location            = var.location # Ubicación (región) de Azure
  resource_group_name = var.resource_group_name # Nombre del grupo de recursos

  ip_configuration {
    name                          = "internal" # Nombre de la configuración IP
    subnet_id                     = azurerm_subnet.internal.id # ID de la subred en la que se ubicará la interfaz de red
    private_ip_address_allocation = "Dynamic" # Asignación dinámica de la dirección IP privada
  }
}

# Configuración de la red virtual (Virtual Network)
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet" # Nombre de la red virtual, basado en el nombre del grupo de recursos
  address_space       = ["10.0.0.0/16"] # Espacio de direcciones IP para la red virtual
  location            = var.location # Ubicación (región) de Azure
  resource_group_name = var.resource_group_name # Nombre del grupo de recursos
}

# Configuración de la subred (Subnet)
resource "azurerm_subnet" "internal" {
  name                 = "internal" # Nombre de la subred
  resource_group_name  = var.resource_group_name # Nombre del grupo de recursos
  virtual_network_name = azurerm_virtual_network.vnet.name # Nombre de la red virtual
  address_prefixes     = ["10.0.2.0/24"] # Prefijo de la dirección IP para la subred
}

# Configuración de la dirección IP pública (Public IP)
resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.vm_name}-pip" # Nombre de la IP pública, basado en el nombre de la VM
  location            = var.location # Ubicación (región) de Azure
  resource_group_name = var.resource_group_name # Nombre del grupo de recursos
  allocation_method   = "Dynamic" # Asignación dinámica de la IP pública
}

# Asociación de la interfaz de red con el pool de direcciones del balanceador de carga
resource "azurerm_network_interface_backend_address_pool_association" "vm_pip_assoc" {
  network_interface_id    = azurerm_network_interface.vm_nic.id # ID de la interfaz de red
  ip_configuration_name   = "internal" # Nombre de la configuración IP en la interfaz de red
  backend_address_pool_id = azurerm_lb_backend_address_pool.bap.id # ID del pool de direcciones del balanceador de carga
}

# Configuración del balanceador de carga (Load Balancer)
resource "azurerm_lb" "vm_lb" {
  name                = "${var.vm_name}-lb" # Nombre del balanceador de carga, basado en el nombre de la VM
  location            = var.location # Ubicación (región) de Azure
  resource_group_name = var.resource_group_name # Nombre del grupo de recursos

  frontend_ip_configuration {
    name                 = "PublicIPAddress" # Nombre de la configuración IP frontal
    public_ip_address_id = azurerm_public_ip.vm_pip.id # ID de la IP pública asociada al balanceador de carga
  }
}

# Configuración del pool de direcciones del balanceador de carga
resource "azurerm_lb_backend_address_pool" "bap" {
  loadbalancer_id     = azurerm_lb.vm_lb.id # ID del balanceador de carga
  name                = "BackendPool" # Nombre del pool de direcciones de backenda
}
