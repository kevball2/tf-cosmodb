terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }

  }
}


provider "azurerm" {
  skip_provider_registration = true
  use_cli                    = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
