resource "azurerm_linux_virtual_machine" "agent_vm" {
  name                            = var.agent_vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.agent_vm_size
  admin_username                  = var.agent_vm_admin_username
  admin_password                  = random_password.agent_password.result
  computer_name                   = var.agent_vm_computer_name
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.agent_nic.id]
  custom_data                     = base64encode(file("${path.module}/runner.sh"))

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = var.agent_vm_os_disk_size_gb
    name                 = "self-hosted-agent-os-disk"
    storage_account_type = var.agent_vm_os_disk_type
  }

  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
}