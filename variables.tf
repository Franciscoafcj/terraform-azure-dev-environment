# -----------------------------------------------------------------------------
# Root Module - Input Variables
# -----------------------------------------------------------------------------

# --- Azure Configuration ---
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "dev-environment"
}

variable "environment" {
  description = "Environment identifier (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# --- Network Configuration ---
variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_prefix" {
  description = "Address prefix for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_prefix" {
  description = "Address prefix for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH and dev ports. IMPORTANT: Restrict to your IP for security (e.g., YOUR_IP/32)"
  type        = string
  default     = "*"
}

# --- Compute Configuration ---
variable "vm_size" {
  description = "Azure VM size for the dev instance"
  type        = string
  default     = "Standard_B2s"
}

variable "disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azuredev"
}

variable "public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# --- Git Configuration ---
variable "git_user_name" {
  description = "Git user name to configure on the instance"
  type        = string
  default     = "Developer"
}

variable "git_user_email" {
  description = "Git user email to configure on the instance"
  type        = string
  default     = "dev@example.com"
}
