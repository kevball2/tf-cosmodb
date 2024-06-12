#-----------------------------------------------------------------------------
# Terraform Block
#-----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.95.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}
#-----------------------------------------------------------------------------
# Providers Blocks
#-----------------------------------------------------------------------------
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  storage_use_azuread        = true
}

#-----------------------------------------------------------------------------
# Vars Blocks
#-----------------------------------------------------------------------------
variable "location" {
  default = "usgovvirginia"
}
#-----------------------------------------------------------------------------
# Locals Blocks
#-----------------------------------------------------------------------------
locals {

}
#-----------------------------------------------------------------------------
# Data Blocks
#-----------------------------------------------------------------------------
# Resource group to create the private DNS zones in
# data "azurerm_resource_group" "this" {
#   name = "rg-test-test"
# }

#-----------------------------------------------------------------------------
# Output Blocks
#-----------------------------------------------------------------------------
output "id" {
  value = azurerm_resource_group.this.name
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE BLOCKS
# ---------------------------------------------------------------------------------------------------------------------
# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}


#-----------------------------------------------------------------------------
# Resource Blocks
#-----------------------------------------------------------------------------
# Creates a resource group
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
  lifecycle {
    ignore_changes = [tags]
  }
}

# # Creates the virtual network 
# resource "azurerm_virtual_network" "vnet" {
#   address_space       = ["192.168.0.0/16"]
#   location            = azurerm_resource_group.this.location
#   name                = module.naming.virtual_network.name_unique
#   resource_group_name = azurerm_resource_group.this.name
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# # Creates the subnet
# resource "azurerm_subnet" "private" {
#   address_prefixes                              = ["192.168.0.0/24"]
#   name                                          = module.naming.subnet.name_unique
#   resource_group_name                           = azurerm_resource_group.this.name
#   virtual_network_name                          = azurerm_virtual_network.vnet.name
#   service_endpoints                             = ["Microsoft.Storage", "Microsoft.KeyVault"]
#   private_endpoint_network_policies_enabled     = false
#   private_link_service_network_policies_enabled = false
# }

# # Creates the network security group
# resource "azurerm_network_security_group" "nsg" {
#   location            = azurerm_resource_group.this.location
#   name                = module.naming.network_security_group.name_unique
#   resource_group_name = azurerm_resource_group.this.name
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# # Creates the network security group association
# resource "azurerm_subnet_network_security_group_association" "private" {
#   network_security_group_id = azurerm_network_security_group.nsg.id
#   subnet_id                 = azurerm_subnet.private.id
# }

# # Creates the network security rule
# resource "azurerm_network_security_rule" "no_internet" {
#   access                      = "Deny"
#   direction                   = "Outbound"
#   name                        = module.naming.network_security_rule.name_unique
#   network_security_group_name = azurerm_network_security_group.nsg.name
#   priority                    = 100
#   protocol                    = "*"
#   resource_group_name         = azurerm_resource_group.this.name
#   destination_address_prefix  = "Internet"
#   destination_port_range      = "*"
#   source_address_prefix       = azurerm_subnet.private.address_prefixes[0]
#   source_port_range           = "*"
# }

# # Creates the user assigned identity
# resource "azurerm_user_assigned_identity" "this" {
#   location            = azurerm_resource_group.this.location
#   name                = module.naming.user_assigned_identity.name_unique
#   resource_group_name = azurerm_resource_group.this.name
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }