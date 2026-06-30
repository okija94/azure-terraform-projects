locals {
  resource_location = "Australia East"

  virtual_network = {
    name          = "app-network"
    address_space = ["10.0.0.0/16"]
  }
}
