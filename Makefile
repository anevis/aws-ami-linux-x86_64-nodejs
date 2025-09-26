# Makefile for AWS AMI Linux x86_64 with Node.js

.PHONY: help init validate build clean

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Packer plugins
	packer init aws-ami-nodejs.pkr.hcl

validate: ## Validate Packer configuration
	packer validate aws-ami-nodejs.pkr.hcl

build: init validate ## Build the AMI
	@if [ -f "variables.pkrvars.hcl" ]; then \
		packer build -var-file="variables.pkrvars.hcl" aws-ami-nodejs.pkr.hcl; \
	else \
		packer build aws-ami-nodejs.pkr.hcl; \
	fi

clean: ## Clean up build artifacts
	rm -f manifest.json
	rm -rf packer_cache/

variables: ## Copy variables template
	cp variables.pkrvars.hcl.example variables.pkrvars.hcl
	@echo "Variables file created. Edit variables.pkrvars.hcl as needed."