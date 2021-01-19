terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26 "
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "tf_state"
    storage_account_name = "tfstate145343"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

locals {
  location = "EastUS"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "network_test"
  location = local.location
}

module "network-security-group1" {
  # outputs:
  # module.network-security-group1.network_security_group_id
  # module.network-security-group1.network_security_group_name
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = local.location
  security_group_name   = "nsg1"
  source_address_prefix = ["10.0.1.0/24"]
  predefined_rules = [
    {
      name     = "SSH"
      priority = "500"
    }
  ]
  depends_on = [azurerm_resource_group.rg]
}

module "network-security-group2" {
  # outputs:
  # module.network-security-group2.network_security_group_id
  # module.network-security-group2.network_security_group_name
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = local.location
  security_group_name   = "nsg2"
  source_address_prefix = ["10.0.2.0/24"]
  predefined_rules = [
    {
      name     = "SSH"
      priority = "500"
    },
    {
      name     = "HTTP"
      priority = "501"
    }
  ]
  depends_on = [azurerm_resource_group.rg]
}

module "network-security-group3" {
  # outputs:
  # module.network-security-group3.network_security_group_id
  # module.network-security-group3.network_security_group_name
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = local.location
  security_group_name   = "nsg3"
  source_address_prefix = ["10.0.3.0/24"]
  predefined_rules = [
    {
      name     = "SSH"
      priority = "500"
    },
    {
      name     = "MSSQL"
      priority = "501"
    }
  ]
  depends_on = [azurerm_resource_group.rg]
}



module "network" {
  # outputs:
  # module.network.vnet_id
  # module.network.vnet_name
  # module.network.vnet_location
  # module.network.vnet_address_space
  # module.network.vnet_subnets
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["central", "webservers", "sqlservers"]
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_network_interface" "webserver" {
  name                = "webserver-nic"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.vnet_subnets[1]
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "sqlserver" {
  name                = "sqlserver-nic"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.vnet_subnets[2]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = "webserver-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.webserver.id
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./id_rsa.pub")
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

resource "azurerm_linux_virtual_machine" "sqlserver" {
  name                = "sqlserver-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  size                = "Standard_D2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.webserver.id
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./id_rsa.pub")
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


# output "webserver_public_ip" {
#   value       = module.webserver-virtual-machine.public_ip_address
#   description = "public IP of web server"
# }
