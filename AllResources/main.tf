
resource "azurerm_resource_group" "appgrp" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_network_security_group" "appnetworksg" {
  name                = local.sg_name
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name
  depends_on = [ azurerm_resource_group.appgrp ]

  security_rule {
    name                       = "AllowRDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAll"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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

# Network interface for app subnet
resource "azurerm_network_interface" "appnetworkinterface" {
  name                = local.network_interface_name
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.appsubnet01.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network interface for web subnet
resource "azurerm_network_interface" "webnetworkinterface" {
  name                = local.web_network_interface_name
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websubet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webip.id
    
  }

  depends_on = [ azurerm_public_ip.webip ]
}

# Create a public IP address
resource "azurerm_public_ip" "webip" {
  name                    = local.web_ip_name
  location                = azurerm_resource_group.appgrp.location
  resource_group_name     = azurerm_resource_group.appgrp.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

# network security group to allow traffic on a particular port
resource "azurerm_network_security_group" "appnsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAll"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# associate NSG to app subnet
resource "azurerm_subnet_network_security_group_association" "appsubnetassoc" {
  subnet_id                 = azurerm_subnet.appsubnet01.id
  network_security_group_id = azurerm_network_security_group.appnetworksg.id
}

# associate NSG to web subnet
resource "azurerm_subnet_network_security_group_association" "websubnetassoc" {
  subnet_id                 = azurerm_subnet.websubet01.id
  network_security_group_id = azurerm_network_security_group.appnetworksg.id
}

# configuration for windows VM
resource "azurerm_windows_virtual_machine" "webvm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = azurerm_resource_group.appgrp.location
  size                = var.vm_size
  admin_username      = var.vm_user_name
  admin_password      = var.vm_user_password
  network_interface_ids = [
    azurerm_network_interface.webnetworkinterface.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
