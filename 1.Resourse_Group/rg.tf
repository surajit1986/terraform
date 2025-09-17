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
    subscription_id = "a79e6ef5-7247-4d2c-9e13-baaba264d746"  

}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "West Europe"
}