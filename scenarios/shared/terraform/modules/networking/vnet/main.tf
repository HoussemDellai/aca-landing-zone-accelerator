## Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = var.networkName
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = var.addressSpace
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.key
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  address_prefixes     = [each.value.addressPrefixes]

  dynamic "delegation" {
    for_each = each.value.service_delegation == null ? [] : [1]
    content {
      name = "delegation"
      dynamic "service_delegation" {
        for_each = each.value.service_delegation
        content {
          name    = service_delegation.value.name
          actions = service_delegation.value.actions
        }
      }
    }
  }
}
