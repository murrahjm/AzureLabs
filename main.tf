terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26 "
    }
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
      priority = "500"
    }
  ]
  depends_on = [azurerm_resource_group.rg]
}

module "network-security-group3" {
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
      priority = "500"
    }
  ]
  depends_on = [azurerm_resource_group.rg]
}


module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["central", "webservers", "sqlservers"]
  depends_on          = [azurerm_resource_group.rg]
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = "azurerm_resource_group.rg.name"

}
