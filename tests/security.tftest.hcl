mock_provider "azurerm" {}

variables {
  subscription_id  = "00000000-0000-0000-0000-000000000000"
  allowed_ssh_cidr = "203.0.113.10/32"
  public_key_path  = "tests/fixtures/test.pub"
}
run "root_plan" {
  command = plan
  assert {
    condition     = output.vscode_server_url == "http://127.0.0.1:8080"
    error_message = "The editor must only be accessed through the local tunnel."
  }
}
run "reject_open_network" {
  command = plan
  variables { allowed_ssh_cidr = "0.0.0.0/0" }
  expect_failures = [var.allowed_ssh_cidr]
}
run "reject_wildcard" {
  command = plan
  variables { allowed_ssh_cidr = "*" }
  expect_failures = [var.allowed_ssh_cidr]
}
run "reject_invalid_cidr" {
  command = plan
  variables { allowed_ssh_cidr = "invalid/32" }
  expect_failures = [var.allowed_ssh_cidr]
}
run "reject_small_disk" {
  command = plan
  variables { disk_size_gb = 10 }
  expect_failures = [var.disk_size_gb]
}
run "reject_shell_in_username" {
  command = plan
  variables { admin_username = "dev;id" }
  expect_failures = [var.admin_username]
}
run "network_ssh_only" {
  command = plan
  module { source = "./modules/networking" }
  variables {
    project_name        = "test"
    location            = "eastus"
    resource_group_name = "test-rg"
  }
  assert {
    condition     = length(azurerm_network_security_group.dev.security_rule) == 1 && alltrue([for rule in azurerm_network_security_group.dev.security_rule : rule.destination_port_range == "22" && rule.source_address_prefix == "203.0.113.10/32"])
    error_message = "Only SSH from the configured CIDR may have an explicit inbound allow rule."
  }
}
run "compute_secure_bootstrap" {
  command = plan
  module { source = "./modules/compute" }
  variables {
    project_name        = "test"
    location            = "eastus"
    resource_group_name = "test-rg"
    subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test/subnets/public"
    git_user_name       = "D'Angelo \"Dev\" $(touch /tmp/unsafe) `id`"
    git_user_email      = "dev@example.com"
  }
  assert {
    condition     = azurerm_linux_virtual_machine.dev.disable_password_authentication
    error_message = "SSH password authentication must remain disabled."
  }
  assert {
    condition     = strcontains(base64decode(azurerm_linux_virtual_machine.dev.custom_data), "bind-addr: 127.0.0.1:8080") && strcontains(base64decode(azurerm_linux_virtual_machine.dev.custom_data), "chmod 600")
    error_message = "The editor must bind to loopback and its credentials must be owner-only."
  }
  assert {
    condition     = !strcontains(base64decode(azurerm_linux_virtual_machine.dev.custom_data), var.git_user_name)
    error_message = "Git identity must be encoded before it is inserted in shell source."
  }
}

