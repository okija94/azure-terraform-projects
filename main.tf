
resource "azurerm_resource_group" "app-grp" {
  name     = "app-grp"
  location = local.resource_location
}


resource "azurerm_virtual_network" "app-network" {
  name                = local.virtual_network.name
  address_space       = local.virtual_network.address_space
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.app-grp.name
}

resource "azurerm_subnet" "app-subnet01" {
    
  name                 = "app-subnet01"
  resource_group_name  = azurerm_resource_group.app-grp.name
  virtual_network_name = azurerm_virtual_network.app-network.name
  address_prefixes     = ["10.0.1.0/24"]

  
}

resource "azurerm_network_interface" "webinterfaces" {
    
  name                = "webinterface0"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.app-grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app-subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webip.id
  }
}

resource "azurerm_public_ip" "webip" {
    
    
  name                = "webip"
  resource_group_name = azurerm_resource_group.app-grp.name
  location            = local.resource_location
  allocation_method   = "Static"


}

resource "azurerm_network_security_group" "app-nsg" {
  name                = "app-nsg"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.app-grp.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  
}


resource "azurerm_subnet_network_security_group_association" "appsubnet01-appsng" {
  subnet_id                 = azurerm_subnet.app-subnet01.id
  network_security_group_id = azurerm_network_security_group.app-nsg.id
}

resource "azurerm_windows_virtual_machine" "webvm01" {
    
  name                = "webvm1"
  resource_group_name = azurerm_resource_group.app-grp.name
  location            = local.resource_location
  size                = "Standard_B2ats_v2"
  admin_username      = var.admin_username
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  
  
  network_interface_ids = [
    azurerm_network_interface.webinterfaces.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}







