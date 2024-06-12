resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = var.sql_databases == null ? {} : var.sql_databases
  account_name        = each.value.account_name
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  throughput          = each.value.throughput

  dynamic "autoscale_settings" {
    for_each = each.value.autoscale_settings == null ? [] : [each.value.autoscale_settings]
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
  depends_on = [ azurerm_cosmosdb_account.this,
                azurerm_private_endpoint.this_managed_dns_zone_groups,
                azurerm_private_endpoint.this_unmanaged_dns_zone_groups
              ]
}


# resource "azurerm_cosmosdb_sql_database" "this" {
#   for_each =            var.sql_databases
#   name                = var.name
#   resource_group_name = var.resource_group_name
#   account_name        = var.account_name
#   throughput          = var.throughput

#   dynamic "autoscale_settings" {
#     for_each = var.value.autoscale_settings == null ? [] : var.value.autoscale_settings
#     content {
#       max_throughput = autoscale_settings.value.max_throughput
#     }
#   }

# }


resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = local.containers == null ? {} : local.containers
  account_name           = azurerm_cosmosdb_account.this.name
  resource_group_name    = azurerm_cosmosdb_account.this.resource_group_name
  database_name          = each.value.database_name
  name                   = each.value.name
  partition_key_path     = each.value.partition_key_path
  analytical_storage_ttl = each.value.analytical_storage_ttl
  default_ttl            = each.value.default_ttl
  partition_key_version  = each.value.partition_key_version
  throughput             = each.value.throughput

  dynamic "autoscale_settings" {
    for_each = each.value.autoscale_settings == null ? [] : [each.value.autoscale_settings]
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }
  dynamic "conflict_resolution_policy" {
    for_each = each.value.conflict_resolution_policy == null ? [] : [each.value.conflict_resolution_policy]
    content {
      mode                          = conflict_resolution_policy.value.mode
      conflict_resolution_path      = conflict_resolution_policy.value.conflict_resolution_path
      conflict_resolution_procedure = conflict_resolution_policy.value.conflict_resolution_procedure
    }
  }
  dynamic "indexing_policy" {
    for_each = each.value.indexing_policy == null ? [] : [each.value.indexing_policy]
    content {
      indexing_mode = indexing_policy.value.indexing_mode

      dynamic "composite_index" {
        for_each = indexing_policy.value.composite_index == null ? [] : indexing_policy.value.composite_index
        content {
          dynamic "index" {
            for_each = composite_index.value.index
            content {
              order = index.value.order
              path  = index.value.path
            }
          }
        }
      }
      dynamic "excluded_path" {
        for_each = indexing_policy.value.excluded_path == null ? [] : indexing_policy.value.excluded_path
        content {
          path = excluded_path.value.path
        }
      }
      dynamic "included_path" {
        for_each = indexing_policy.value.included_path == null ? [] : indexing_policy.value.included_path
        content {
          path = included_path.value.path
        }
      }
      dynamic "spatial_index" {
        for_each = indexing_policy.value.spatial_index == null ? [] : indexing_policy.value.spatial_index
        content {
          path = spatial_index.value.path
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
  dynamic "unique_key" {
    for_each = each.value.unique_key == null ? {} : each.value.unique_key
    content {
      paths = unique_key.value.paths
    }
  }
  depends_on = [ azurerm_cosmosdb_sql_database.this ]
}







# resource "azurerm_cosmosdb_sql_container" "this" {
#   for_each = local.containers == null ? {} : local.containers
#   name                   = each.value.name
#   resource_group_name    = each.value.resource_group_name
#   account_name           = each.value.account_name
#   database_name          = each.value.database_name
#   partition_key_path     = each.value.partition_key_path
#   partition_key_version  = each.value.partition_key_version
#   throughput             = each.value.throughput
#   default_ttl            = each.value.default_ttl
#   analytical_storage_ttl = each.value.analytical_storage_ttl

#   dynamic "unique_key" {
#     for_each = local.containers == null ? {} : local.containers
#     content {
#       paths = each.value.unique_key.paths
#     }
#   }

#   dynamic "autoscale_settings" {
#     for_each = local.containers == null ? {} : local.containers
#     content {
#       max_throughput = each.value.max_throughput
#     }
#   }

#   dynamic "indexing_policy" {
#     for_each = local.containers == null ? {} : local.containers
#     content {
#       indexing_mode = each.value.indexing_mode

#       included_path {
#         path = each.value.path
#       }

#       excluded_path {
#         path = each.value.path
#       }

#       composite_index {
#         index {
#           path  = composite_index.value.path
#           order = composite_index.value.order
#         }
#       }

#       spatial_index {
#         path = spatial_index.value.path
#       }
#     }
#   }

  # dynamic "conflict_resolution_policy" {
  #   for_each = var.indexing_policy == null ? {} : var.indexing_policy
  #   content {
  #     mode                          = each.value.mode
  #     conflict_resolution_path      = each.value.conflict_resolution_path
  #     conflict_resolution_procedure = each.value.conflict_resolution_procedure
  #   }
  # }
# }
