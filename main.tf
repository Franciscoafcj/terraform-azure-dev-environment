# -----------------------------------------------------------------------------
# Root module - orchestrates resource group, networking and compute modules
# -----------------------------------------------------------------------------

# --- Resource Group ---
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --- Networking Module ---
module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_address_space  = var.vnet_address_space
  public_subnet_prefix  = var.public_subnet_prefix
  private_subnet_prefix = var.private_subnet_prefix
  allowed_ssh_cidr    = var.allowed_ssh_cidr
}

# --- Compute Module ---
module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.networking.public_subnet_id
  vm_size             = var.vm_size
  disk_size_gb        = var.disk_size_gb
  admin_username      = var.admin_username
  public_key_path     = var.public_key_path
  git_user_name       = var.git_user_name
  git_user_email      = var.git_user_email
}
