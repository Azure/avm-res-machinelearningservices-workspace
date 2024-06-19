module "vnet" {
  source  = "Azure/terraform-azurerm-vnet/azurerm"
  version = "~> 0.4"

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.vnet_name
  address_space       = var.vnet_address_space

  subnets = var.subnets

  tags = var.tags

  count = var.associated_vnet == null ? 1 : 0
}
