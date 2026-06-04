# -----------------------------------------------------------------------------
# Compute Module - Outputs
# -----------------------------------------------------------------------------

output "vm_id" {
  description = "ID of the Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.dev.id
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.dev.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.dev.private_ip_address
}

output "vm_name" {
  description = "Name of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.dev.name
}
