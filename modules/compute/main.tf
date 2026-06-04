# -----------------------------------------------------------------------------
# Compute Module - Main Configuration
# Provisions an Azure Linux VM with Ubuntu 24.04 LTS
# -----------------------------------------------------------------------------

# Public IP for the VM
resource "azurerm_public_ip" "dev" {
  name                = "${var.project_name}-${var.environment}-vm-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name        = "${var.project_name}-${var.environment}-vm-pip"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Network Interface
resource "azurerm_network_interface" "dev" {
  name                = "${var.project_name}-${var.environment}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev.id
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "dev" {
  name                = "${var.project_name}-${var.environment}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.dev.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "${var.project_name}-${var.environment}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    git_user_name  = var.git_user_name
    git_user_email = var.git_user_email
    admin_username = var.admin_username
  }))

  # Disable password authentication for security
  disable_password_authentication = true

  tags = {
    Name        = "${var.project_name}-dev-instance"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
