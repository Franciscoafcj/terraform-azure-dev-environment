# -----------------------------------------------------------------------------
# Root module outputs
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "vm_public_ip" {
  description = "Public IP of the dev VM"
  value       = module.compute.vm_public_ip
}

output "vscode_server_url" {
  description = "Local URL available after opening the SSH tunnel"
  value       = "http://127.0.0.1:8080"
}

output "ssh_command" {
  description = "SSH command to connect to the dev VM"
  value       = "ssh ${var.admin_username}@${module.compute.vm_public_ip}"
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "vm_name" {
  description = "Name of the dev VM"
  value       = module.compute.vm_name
}

output "vscode_tunnel_command" {
  description = "Keep this SSH tunnel running while using the local editor URL"
  value       = "ssh -N -o ExitOnForwardFailure=yes -L 127.0.0.1:8080:127.0.0.1:8080 ${var.admin_username}@${module.compute.vm_public_ip}"
}
