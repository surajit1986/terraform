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

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "West Europe"
}