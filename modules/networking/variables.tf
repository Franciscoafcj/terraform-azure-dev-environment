# ---------------------------------------------------------------------------
# Networking Module – Input Variables
# ---------------------------------------------------------------------------

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (CIDR notation)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_prefix" {
  description = "Address prefix for the public subnet (CIDR notation)."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_prefix" {
  description = "Address prefix for the private subnet (CIDR notation)."
  type        = string
  default     = "10.0.2.0/24"
}

variable "location" {
  description = "Azure region where the networking resources will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that will contain the networking resources."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH and dev ports. Restrict this to your public IP (e.g. \"203.0.113.10/32\") for better security."
  type        = string
  default     = "*"
}

variable "project_name" {
  description = "Project name used as a prefix for all resource names."
  type        = string
}

variable "environment" {
  description = "Environment identifier (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}
