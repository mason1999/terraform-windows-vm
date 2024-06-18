resource "azurerm_public_ip" "this" {
  count               = var.enable_public_ip_address == true ? 1 : 0
  name                = "public-ip-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Ip configuration
  ip_configuration {
    name                          = "ip-configuration-${var.suffix}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.enable_public_ip_address == true ? azurerm_public_ip.this[0].id : null
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                  = "vm-${var.suffix}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_DS1_v2"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    name                 = "windows-disk-${var.suffix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

data "template_file" "init" {
  count    = var.run_init_script == true ? 1 : 0
  template = file("${path.module}/init.ps1")
  vars = {
    virtual_machine_name = "${azurerm_windows_virtual_machine.this.name}"
  }
}

resource "azurerm_virtual_machine_extension" "this" {
  count                = var.run_init_script == true ? 1 : 0
  name                 = "windows-init-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.init[0].rendered)}')) | Out-File -filepath init.ps1\" && powershell -ExecutionPolicy Unrestricted -File init.ps1 -virtual_machine_name ${data.template_file.init[0].vars.virtual_machine_name}"
}
SETTINGS
}
