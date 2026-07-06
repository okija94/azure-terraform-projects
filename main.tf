
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
  address_prefixes     = ["10.0.0.0/24"]
}





resource "azurerm_network_interface" "appinterfaces" {

  name                = "appinterface0"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.app-grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app-subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.appip.id
  }
}

resource "azurerm_public_ip" "appip" {


  name                = "appip"
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

  security_rule {
    name                       = "AllowTraffic"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}


resource "azurerm_subnet_network_security_group_association" "appsubnet01-appsng" {
  subnet_id                 = azurerm_subnet.app-subnet01.id
  network_security_group_id = azurerm_network_security_group.app-nsg.id
}

resource "azurerm_windows_virtual_machine" "appvm" {

  name                = "appvm0"
  resource_group_name = azurerm_resource_group.app-grp.name
  location            = local.resource_location
  size                = "Standard_B2ats_v2"
  admin_username      = var.admin_username
  admin_password      = azurerm_key_vault_secret.vmpassword.value


  network_interface_ids = [
    azurerm_network_interface.appinterfaces.id,
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



resource "azurerm_subnet" "web-subnet01" {
  name                 = "web-subnet01"
  resource_group_name  = azurerm_resource_group.app-grp.name
  virtual_network_name = azurerm_virtual_network.app-network.name
  address_prefixes     = ["10.0.1.0/24"]
}





resource "azurerm_network_interface" "webinterfaces" {
  name                = "webinterfaces0"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.app-grp.name





  ip_configuration {
    name                          = "webip"
    subnet_id                     = azurerm_subnet.web-subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.webip.id
  }
}

resource "azurerm_linux_virtual_machine" "webvm" {
  name                = "webvm"
  resource_group_name = azurerm_resource_group.app-grp.name
  location            = local.resource_location
  size                = "Standard_B2ats_v2"

  admin_username                  = var.admin_username
  admin_password                  = azurerm_key_vault_secret.vmpassword.value
  disable_password_authentication = false
  custom_data                     = data.local_file.cloudinit.content_base64

  network_interface_ids = [
    azurerm_network_interface.webinterfaces.id,
  ]



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

data "local_file" "cloudinit" {
  filename = "cloudinit"
}

resource "azurerm_public_ip" "webip" {


  name                = "webip"
  resource_group_name = azurerm_resource_group.app-grp.name
  location            = local.resource_location
  allocation_method   = "Static"


}


resource "azurerm_subnet_network_security_group_association" "web-subnet01-appsng" {
  subnet_id                 = azurerm_subnet.web-subnet01.id
  network_security_group_id = azurerm_network_security_group.web-subnet01-appsng.id
}


resource "azurerm_network_security_group" "web-subnet01-appsng" {
  name                = "web-subnet01-appsng"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.app-grp.name

  security_rule {
    name                       = "allow-internet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}






