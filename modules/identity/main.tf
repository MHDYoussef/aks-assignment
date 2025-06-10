resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aks-identity-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group
}