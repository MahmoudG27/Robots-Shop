# Create Private Network Interface for Azure DevOps Agent
resource "azurerm_network_interface" "agent_nic" {
  name                = var.agent_nic_name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "agent-nic-config"
    subnet_id                     = var.infra_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.agent_nic_private_ip
  }
}