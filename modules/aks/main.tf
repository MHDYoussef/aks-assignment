module "networking" {
  source         = "../networking"
  environment    = var.environment
  location       = var.location
  resource_group = var.resource_group
}

module "identity" {
  source         = "../identity"
  environment    = var.environment
  location       = var.location
  resource_group = var.resource_group
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "aks-${var.environment}"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = module.networking.aks_subnet_id
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = module.identity.identity_id
  }

  api_server_access_profile {
    enable_private_cluster = true
  }

  azure_active_directory_role_based_access_control {
    managed = true
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    outbound_type = "userDefinedRouting"
  }
}

resource "azurerm_public_ip" "jumpbox" {
  name                = "jumpbox-pip-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "jumpbox-nic-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking.jumpbox_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }

  network_security_group_id = module.networking.jumpbox_nsg_id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                  = "jumpbox-${var.environment}"
  resource_group_name   = var.resource_group
  location              = var.location
  size                  = "Standard_B2ms"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.jumpbox.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}