resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = var.admin_password
  key_vault_id = data.azurerm_key_vault.appvault30003000.id
}

data "azurerm_key_vault" "appvault30003000" {
  name                = "appvault30003000"
  resource_group_name = "security-grp"

}