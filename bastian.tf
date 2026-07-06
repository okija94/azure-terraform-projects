
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.app-grp.name
  virtual_network_name = azurerm_virtual_network.app-network.name
  address_prefixes     = ["10.0.2.0/26"]
}

resource "azurerm_public_ip" "bastianip" {


  name                = "bastianip"
  resource_group_name = azurerm_resource_group.app-grp.name
  location            = local.resource_location
  allocation_method   = "Static"


}
resource "azurerm_bastion_host" "bastian" {
  name                = "bastian"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.app-grp.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastianip.id
  }
}

  

  