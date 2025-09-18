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

resource "azurerm_storage_account" "appstore" {
  name                     = "terraformappstore"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = azurerm_resource_group.appgrp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [ azurerm_resource_group.appgrp ]

  tags = {
    environment = "terraform-dev"
  }
}

resource "azurerm_storage_container" "tfblobcontainer" {
  name                  = "tfblobcontainer"
  storage_account_id    = azurerm_storage_account.appstore.id
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.appstore ]
}

resource "azurerm_storage_blob" "tfstorageblob" {
  name                   = "myPic.jpg"
  storage_account_name   = azurerm_storage_account.appstore.name
  storage_container_name = azurerm_storage_container.tfblobcontainer.name
  type                   = "Block"
  source                 = "myPic.jpg"
  depends_on = [ azurerm_storage_container.tfblobcontainer, azurerm_storage_account.appstore ]
}