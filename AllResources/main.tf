
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
  address_space       = [local.address_spaces[0]]
  dns_servers         = [local.address_spaces[1], local.address_spaces[2]]
  depends_on = [ azurerm_resource_group.appgrp ]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "websubet01" {
  name                 = local.subnets[0].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes     = local.subnets[0].address_prefixes
}

resource "azurerm_subnet" "appsubnet01" {
  name                 = local.subnets[1].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes     = local.subnets[1].address_prefixes
}

resource "azurerm_network_interface" "appnetworkinterface" {
  name                = local.network_interface_name
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websubet01.id
    private_ip_address_allocation = "Dynamic"
  }
}