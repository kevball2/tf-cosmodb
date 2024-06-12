## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
}

# This module get the public-ip where TF is excecuted
module "public_ip" {
  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
}



# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "default" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  name                          = "cosmos-pep-testing-ecmg" # TODO update with module.naming.<RESOURCE_TYPE>.name_unique
  resource_group_name           = azurerm_resource_group.this.name
  location                      = "usgovarizona" #azurerm_resource_group.this.location
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  capabilities = [
    {
      name = "EnableServerless"
    }
  ]
  public_network_access_enabled = true
  ip_range_filter               = "${module.public_ip.public_ip}"
  sql_databases = {
    "database1" = {
      account_name        = module.naming.cosmosdb_account.name_unique
      name                = "database1"
      resource_group_name = azurerm_resource_group.this.name
    }
    "database2" = {
      account_name        = module.naming.cosmosdb_account.name_unique
      name                = "database2"
      resource_group_name = azurerm_resource_group.this.name
      containers = {
        "container1" = {
          name               = "container1"
          partition_key_path = "/definition/id"
        }
      }
    }
  }
  consistency_policy = {
    consistency_level = "Strong"
  }
  geo_location = [{
    location          = "usgovarizona"
    failover_priority = 0
  }]
  private_endpoints = {
    endpoint1 = {
      name = "pep-cosmos-pep-testing-ecmg"
      subnet_resource_id = "/subscriptions/22f009ad-237a-4316-b8e7-c00b67314a5b/resourceGroups/rg-ecmg_module-networking-dev-ugv/providers/Microsoft.Network/virtualNetworks/vnet-ecmg_module-dev-ugv/subnets/snet-nsep-ps-main"
      subresource_name = ["Sql"]
      private_dns_zone_resource_ids = ["/subscriptions/f43f522e-d704-49c7-8b54-fed1f88ce691/resourceGroups/rg-ecmg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.us"]
      network_interface_name = "nic-pep-cosmos-pep-testing-ecmg"
      location = "usgovvirginia"
      ip_configurations = {
        cosmos-pep-testing-ecmg = {
          name = "cosmos-pep-testing-ecmg"
          private_ip_address = "10.107.14.77"
          member_name = "cosmos-pep-testing-ecmg"
        }
        cosmos-pep-testing-ecmg-usgovarizona = {
          name = "cosmos-pep-testing-ecmg-usgovarizona"
          private_ip_address = "10.107.14.78"
          member_name = "cosmos-pep-testing-ecmg-usgovarizona"
        }
      }

    }


  }
  private_endpoints_manage_dns_zone_group = true
}
