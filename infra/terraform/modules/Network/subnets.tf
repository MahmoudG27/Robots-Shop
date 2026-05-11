resource "azurerm_subnet" "infra_subnet" {
  name                 = var.infra_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.project_vnet.name
  address_prefixes     = [var.infra_subnet_address]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.project_vnet.name
  address_prefixes     = [var.aks_subnet_address]
}

resource "azurerm_subnet" "mssql_subnet" {
  name                 = var.mssql_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.project_vnet.name
  address_prefixes     = [var.mssql_subnet_address]
}

resource "azurerm_subnet" "vpn_subnet" {
  name                 = var.vpn_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.project_vnet.name
  address_prefixes     = [var.vpn_subnet_address]
}

# azurerm_subnet.appgw_subnet:
resource "azurerm_subnet" "appgw_subnet" {
  name                 = var.appgw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.project_vnet.name
  address_prefixes     = [var.appgw_subnet_address]

  delegation {
    name = "Microsoft.Network/applicationGateways"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
      name = "Microsoft.Network/applicationGateways"
    }
  }
}