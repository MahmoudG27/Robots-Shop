resource "azurerm_public_ip" "vpn_gw_pip" {
  name                = var.vpn_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = var.vpn_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  sku           = var.vpn_gateway_sku
  generation    = "Generation1"
  active_active = false
  enable_bgp    = false

  ip_configuration {
    name                          = "vpngw-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.vpn_subnet_id
  }

  vpn_client_configuration {
    address_space = var.vpn_address_pool

    root_certificate {
      name             = "P2SRootCert"
      public_cert_data = filebase64("${path.module}/certs/P2SRootCert.cer")
      # 👆 this is the Base64-encoded .cer file from your self-signed cert
    }
  }
}