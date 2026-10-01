.PHONY: help init plan apply destroy fmt validate test output ssh clean

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform
	@echo "==> Initializing Terraform..."
	terraform init

plan: ## Show execution plan
	@echo "==> Planning infrastructure changes..."
	terraform plan

apply: ## Apply infrastructure changes
	@echo "==> Applying infrastructure..."
	terraform apply

destroy: ## Destroy all infrastructure
	@echo "==> Destroying infrastructure..."
	terraform destroy

fmt: ## Format Terraform files
	@echo "==> Formatting Terraform files..."
	terraform fmt -recursive

test: ## Run plan tests with mocked Azure provider (no cloud resources)
	terraform test

validate: ## Validate Terraform configuration
	@echo "==> Validating configuration..."
	terraform validate

output: ## Show Terraform outputs
	@echo "==> Showing outputs..."
	terraform output

ssh: ## SSH into the dev VM
	@echo "==> Connecting to dev VM via SSH..."
	$$(terraform output -raw ssh_command)

clean: ## Remove Terraform local files
	@echo "==> Cleaning up..."
	rm -rf .terraform
	@echo "Preserving dependency lock and state files"
