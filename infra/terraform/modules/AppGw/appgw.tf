resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_http2 = false
  fips_enabled = false

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.appgw_subnet
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.pip_appgw.id
  }

  frontend_port {
    name = "httpPort"
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  backend_address_pool {
    name = "bepool"
  }

  backend_http_settings {
    name                  = "setting"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 30
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    priority                   = 10010
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "bepool"
    backend_http_settings_name = "setting"
  }
}