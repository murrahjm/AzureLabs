terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26 "
    }
  }
}

provider "azurerm" {
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "FirstResourceGroup"
  location = "eastus"
  tags = {
    "Environment" = "Lab"
  }
}
