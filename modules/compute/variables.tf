# -----------------------------------------------------------------------------
# Compute Module - Input Variables
# -----------------------------------------------------------------------------

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "subnet_id" {
  description = "ID of the subnet where the VM will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azuredev"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,31}$", var.admin_username)) && !contains(["root", "admin", "administrator"], var.admin_username)
    error_message = "Use a non-reserved Linux username starting with a lowercase letter (maximum 32 characters)."
  }
}

variable "public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
  validation {
    condition     = var.disk_size_gb >= 30 && var.disk_size_gb <= 4095 && floor(var.disk_size_gb) == var.disk_size_gb
    error_message = "OS disk size must be an integer between 30 and 4095 GiB."
  }
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "git_user_name" {
  description = "Git user name to configure on the VM"
  type        = string
  default     = "Developer"
}

variable "git_user_email" {
  description = "Git user email to configure on the VM"
  type        = string
  default     = "dev@example.com"
}
