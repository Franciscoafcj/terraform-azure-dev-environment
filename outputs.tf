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
  description = "URL to access VS Code Server in the browser"
  value       = "http://${module.compute.vm_public_ip}:8080"
}

output "ssh_command" {
  description = "SSH command to connect to the dev VM"
  value       = "ssh -i ~/.ssh/id_rsa ${var.admin_username}@${module.compute.vm_public_ip}"
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "vm_name" {
  description = "Name of the dev VM"
  value       = module.compute.vm_name
}
