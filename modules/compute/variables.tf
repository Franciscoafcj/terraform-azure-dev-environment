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
