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
  consistency_policy = {
    consistency_level = "Strong"
  }
  geo_location = [{
    location          = "eastus"
    failover_priority = 0
  }]
  ip_range_filter = "52.244.48.71,140.162.13.171"
}
