terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
}

provider "azurerm" {
    features {
      
    }  
 

}

locals {
  rg_name = "app-grp"
  location ="West Europe"
  sg_name = "app-network-sg"
  network_name = "app-network"
  subnet_1_name = "websubnet01"
  subnet_2_name = "appsubnet02"
}

resource "azurerm_resource_group" "appgrp" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_network_security_group" "appnetworksg" {
  name                = local.sg_name
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name
  depends_on = [ azurerm_resource_group.appgrp ]
}

resource "azurerm_virtual_network" "appnetwork" {
  name                = local.network_name
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  depends_on = [ azurerm_resource_group.appgrp ]

  subnet {
    name             = local.subnet_1_name
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = local.subnet_2_name
    address_prefixes = ["10.0.2.0/24"]
    security_group   = azurerm_network_security_group.appnetworksg.id
  }

  tags = {
    environment = "dev"
  }
}