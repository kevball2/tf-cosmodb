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
  name                          = module.naming.cosmosdb_account.name_unique # TODO update with module.naming.<RESOURCE_TYPE>.name_unique
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
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
    location          = "eastus"
    failover_priority = 0
  }]
}
