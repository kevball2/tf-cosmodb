# TODO: insert resources here.
#data "azurerm_resource_group" "parent" {
#  count = var.location == null ? 1 : 0
#
#  name = var.resource_group_name
#}

resource "azurerm_cosmosdb_account" "this" {
  location                              = var.location
  name                                  = var.name
  offer_type                            = var.offer_type
  resource_group_name                   = var.resource_group_name
  access_key_metadata_writes_enabled    = var.access_key_metadata_writes_enabled
  analytical_storage_enabled            = var.analytical_storage_enabled
  automatic_failover_enabled            = var.automatic_failover_enabled
  create_mode                           = var.create_mode
  default_identity_type                 = var.default_identity_type
  free_tier_enabled                     = var.free_tier_enabled
  ip_range_filter                       = local.ip_range_filter
  is_virtual_network_filter_enabled     = var.is_virtual_network_filter_enabled
  key_vault_key_id                      = var.key_vault_key_id
  kind                                  = var.kind
  local_authentication_disabled         = var.local_authentication_disabled
  minimal_tls_version                   = var.minimal_tls_version
  mongo_server_version                  = var.mongo_server_version
  multiple_write_locations_enabled      = var.multiple_write_locations_enabled
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = var.network_acl_bypass_ids
  partition_merge_enabled               = var.partition_merge_enabled
  public_network_access_enabled         = var.public_network_access_enabled
  tags                                  = var.tags

  dynamic "consistency_policy" {
    for_each = [var.consistency_policy]
    content {
      consistency_level       = consistency_policy.value.consistency_level
      max_interval_in_seconds = consistency_policy.value.max_interval_in_seconds
      max_staleness_prefix    = consistency_policy.value.max_staleness_prefix
    }
  }
  dynamic "geo_location" {
    for_each = var.geo_location == null ? [] : var.geo_location
    content {
      failover_priority = geo_location.value.failover_priority
      location          = geo_location.value.location
      zone_redundant    = geo_location.value.zone_redundant
    }
  }
  dynamic "analytical_storage" {
    for_each = var.analytical_storage == null ? [] : [var.analytical_storage]
    content {
      schema_type = analytical_storage.value.schema_type
    }
  }
  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]
    content {
      type                = backup.value.type
      interval_in_minutes = backup.value.interval_in_minutes
      retention_in_hours  = backup.value.retention_in_hours
      storage_redundancy  = backup.value.storage_redundancy
      tier                = backup.value.tier
    }
  }
  dynamic "capabilities" {
    for_each = var.capabilities == null ? [] : var.capabilities
    content {
      name = capabilities.value.name
    }
  }
  dynamic "capacity" {
    for_each = var.capacity == null ? [] : [var.capacity]
    content {
      total_throughput_limit = capacity.value.total_throughput_limit
    }
  }
  dynamic "cors_rule" {
    for_each = var.cors_rule == null ? [] : [var.cors_rule]
    content {
      allowed_headers    = cors_rule.value.allowed_headers
      allowed_methods    = cors_rule.value.allowed_methods
      allowed_origins    = cors_rule.value.allowed_origins
      exposed_headers    = cors_rule.value.exposed_headers
      max_age_in_seconds = cors_rule.value.max_age_in_seconds
    }
  }
 dynamic "identity" {
    for_each = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? { this = var.managed_identities } : {}
    content {
      type         = identity.value.system_assigned && length(identity.value.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(identity.value.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  dynamic "restore" {
    for_each = var.restore == null ? [] : [var.restore]
    content {
      restore_timestamp_in_utc   = restore.value.restore_timestamp_in_utc
      tables_to_restore          = restore.value.tables_to_restore
      source_cosmosdb_account_id = restore.source_cosmosdb_account_id

      dynamic "database" {
        for_each = restore.value.database == null ? [] : restore.value.database
        content {
          name             = database.value.name
          collection_names = database.value.collection_names
        }
      }
      dynamic "gremlin_database" {
        for_each = restore.value.gremlin_database == null ? [] : restore.value.gremlin_database
        content {
          name        = gremlin_database.value.name
          graph_names = gremlin_database.value.graph_names
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = var.cosmosdb_account_timeouts == null ? [] : [var.cosmosdb_account_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rule == null ? [] : var.virtual_network_rule
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }
}






#
# resource "azurerm_cosmosdb_account" "this" {
#   name                                  = var.name
#   resource_group_name                   = var.resource_group_name
#   location                              = var.location
#   tags                                  = var.tags
#   minimal_tls_version                   = var.minimal_tls_version
#   offer_type                            = var.offer_type
#   create_mode                           = var.create_mode
#   default_identity_type                 = var.default_identity_type
#   kind                                  = var.kind
#   ip_range_filter                       = var.ip_range_filter
#   free_tier_enabled                     = var.free_tier_enabled
#   analytical_storage_enabled            = var.analytical_storage_enabled
#   automatic_failover_enabled            = var.automatic_failover_enabled
#   partition_merge_enabled               = var.partition_merge_enabled
#   public_network_access_enabled         = var.public_network_access_enabled
#   is_virtual_network_filter_enabled     = var.is_virtual_network_filter_enabled
#   key_vault_key_id                      = var.key_vault_key_id
#   multiple_write_locations_enabled      = var.multiple_write_locations_enabled
#   access_key_metadata_writes_enabled    = var.access_key_metadata_writes_enabled
#   mongo_server_version                  = var.mongo_server_version
#   network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
#   network_acl_bypass_ids                = var.network_acl_bypass_ids
#   local_authentication_disabled         = var.local_authentication_disabled


#   dynamic "analytical_storage" {
#     for_each = var.analytical_storage == null ? {} : var.analytical_storage
#     content {
#       schema_type = each.value.schema_type
#     }
#   }

#   dynamic "capacity" {
#     for_each = var.capacity == null ? {} : var.capacity
#     content {
#       total_throughput_limit = capacity.value.total_throughput_limit
#     }
#   }

#   dynamic "consistency_policy" {
#     for_each = var.consistency_policy == null ? {} : var.consistency_policy
#     content {
#       consistency_level       = each.value.consistency_level
#       max_interval_in_seconds = each.value.max_interval_in_seconds
#       max_staleness_prefix    = each.value.max_staleness_prefix
#     }
#   }

#   dynamic "geo_location" {
#     for_each = var.geo_location == null ? [] : var.geo_location
#     content {
#       location          = each.value.location
#       failover_priority = each.value.failover_priority
#       zone_redundant    = each.value.zone_redundant
#     }
#   }

#   dynamic "capabilities" {
#     for_each = var.value.capabilities
#     content {
#       name = capabilities.value.name
#     }
#   }

#   dynamic "virtual_network_rule" {
#     for_each = var.value.virtual_network_rule == null ? [] : var.value.virtual_network_rule
#     content {
#       id                                   = virtual_network_rule.value.id
#       ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
#     }
#   }

#   dynamic "backup" {
#     for_each = var.backup == null ? [] : var.backup
#     content {
#       type                = each.value.type
#       tier                = each.value.tier
#       interval_in_minutes = each.value.interval_in_minutes
#       retention_in_hours  = each.value.retention_in_hours
#       storage_redundancy  = each.value.storage_redundancy
#     }
#   }

#   dynamic "cors_rule" {
#     for_each = var.cors_rule == null ? {} : var.cors_rule
#     content {
#       allowed_headers    = each.value.allowed_headers
#       allowed_methods    = each.value.allowed_methods
#       allowed_origins    = each.value.allowed_origins
#       exposed_headers    = each.value.exposed_headers
#       max_age_in_seconds = each.value.max_age_in_seconds
#     }
#   }

#   dynamic "identity" {
#     for_each = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? { this = var.managed_identities } : {}
#     content {
#       type         = identity.value.system_assigned && length(identity.value.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(identity.value.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
#       identity_ids = identity.value.user_assigned_resource_ids
#     }
#   }

#   dynamic "restore" {
#     for_each = var.restore == null ? {} : var.restore
#     content {
#       source_id = each.value.source_id
#       restore_timestamp_in_utc   = each.value.restore_timestamp_in_utc
#       tables_to_restore          = each.value.tables_to_restore

#       # database {
#       #   name             = database.value.name
#       #   collection_names = database.value.collection_names
#       # }

#       # gremlin_database {
#       #   name        = gremlin_database.value.name
#       #   graph_names = gremlin_database.value.graph_names
#       # }
#     }
#   }

# }

# required AVM resources interfaces
# resource "azurerm_management_lock" "this" {
#   count = var.lock.kind != "None" ? 1 : 0

#   lock_level = var.lock.kind
#   name       = coalesce(var.lock.name, "lock-${var.name}")
#   scope      = azurerm_resource_group.TODO.id # TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
# }

resource "azurerm_role_assignment" "cosmosdb_account" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_cosmosdb_account.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}


