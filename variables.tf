variable "name" {
  type        = string
  description = "The name of the resource."

  # validation {
  #   condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
  #   error_message = "The name must be between 3 and 24 characters, valid characters are lowercase letters and numbers."
  # }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
  "Required. The name of the resource group where the resources will be deployed."
  DESCRIPTION

  validation {
    condition     = can(regex("^[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()-]{1}$", var.resource_group_name))
    error_message = <<ERROR_MESSAGE
    The resource group name must meet the following requirements:
    - Between 1 and 90 characters long.
    - Can only contain Alphanumerics, underscores, parentheses, hyphens, periods.
    - Cannot end in a period
    ERROR_MESSAGE
  }
}

variable "location" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Azure region where the resource should be deployed.
If null, the location will be inferred from the resource group location.
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Custom tags to apply to the resource."
}

variable "minimal_tls_version" {
  type        = string
  default     = "Tls12"
  description = "(Optional) The minimum supported TLS version for the storage account. Possible values are `Tls`, `Tls11`, and `Tls12`. Defaults to `Tls12`"
  nullable    = false
  validation {
    condition     = contains(["Tls", "Tls11", "Tls12"], var.minimal_tls_version)
    error_message = "Invalid value for TLS version. Valid options are `Tls`, `Tls11`, and `Tls12`."
  }
}

variable "offer_type" {
  type        = string
  default     = "Standard"
  description = "(Required) Specifies the Offer Type to use for this CosmosDB Account; currently, this can only be set to Standard.`"
  nullable    = false
  validation {
    condition     = contains(["Standard"], var.offer_type)
    error_message = "Invalid value offer type. Valid options are `Standard`."
  }
}

# create_mode can only be defined when the backup.type is set to Continuous.
variable "create_mode" {
  type        = string
  default     = null
  description = "(Optional) The creation mode for the CosmosDB Account. Possible values are Default and Restore. Changing this forces a new resource to be created."
}

# When default_identity_type is a UserAssignedIdentity it must include the User Assigned Identity ID in the following format:
# UserAssignedIdentity=/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{userAssignedIdentityName}.
variable "default_identity_type" {
  type        = string
  default     = "FirstPartyIdentity"
  description = "(Optional) The default identity for accessing Key Vault. Possible values are FirstPartyIdentity, SystemAssignedIdentity or UserAssignedIdentity. Defaults to FirstPartyIdentity."
  nullable    = false
  validation {
    condition     = contains(["FirstPartyIdentity", "SystemAssignedIdentity", "UserAssignedIdentity"], var.default_identity_type)
    error_message = "Invalid value default identity type. Valid options are 'FirstPartyIdentity', 'SystemAssignedIdentity', 'UserAssignedIdentity'."
  }
}

variable "kind" {
  type        = string
  default     = "GlobalDocumentDB"
  description = "(Optional) Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB, MongoDB and Parse. Defaults to GlobalDocumentDB. Changing this forces a new resource to be created."
  nullable    = false
  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "Invalid value kind. Valid options are 'GlobalDocumentDB', 'MongoDB', 'Parse'."
  }
}

variable "allow_azure_portal_access" {
  type = bool
  default = true
  description = "This adds access to your account from Azure Cosmos DB Portal middle-tier IPs. You may want to enable this to allow portal features such as Data Explorer for all APIs."
}

variable "ip_range_filter" {
  type        = string
  description = "To enable the 'Allow access from the Azure portal' behavior, you should add the IP addresses provided by the documentation to this list. To enable the 'Accept connections from within public Azure datacenters' behavior, you should add 0.0.0.0 to the list, see the documentation for more details."
}


variable "free_tier_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable the Free Tier pricing option for this Cosmos DB account. Defaults to false."
}

variable "analytical_storage_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable Analytical Storage option for this Cosmos DB account. Defaults to false."
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable automatic failover for this Cosmos DB account."
}

variable "partition_merge_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Is partition merge on the Cosmos DB account enabled? Defaults to false."
}

# should this default to false?
variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether or not public network access is allowed for this CosmosDB account. Defaults to false."
}

variable "is_virtual_network_filter_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enables virtual network filtering for this Cosmos DB account. Defaults to false."
}

variable "key_vault_key_id" {
  type        = string
  default = null
  description = "When referencing an azurerm_key_vault_key resource, use versionless_id instead of id. In order to use a Custom Key from Key Vault for encryption you must grant Azure Cosmos DB Service access to your key vault."
}

variable "multiple_write_locations_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable multiple write locations for this Cosmos DB account. Defaults to false."
}

# should be false?
variable "access_key_metadata_writes_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Is write operations on metadata resources (databases, containers, throughput) via account keys enabled? Defaults to true."
}

variable "mongo_server_version" {
  type        = string
  default     = null
  description = "(Optional) The Server Version of a MongoDB account. Possible values are 4.2, 4.0, 3.6, and 3.2."
  # need validation for null?
  validation {
    condition     = var.mongo_server_version != null ? contains(["4.2", "4.0", "3.6", "3.2"], var.mongo_server_version) : true
    error_message = "Invalid value kind. Valid options are 'GlobalDocumentDB', 'MongoDB', 'Parse'."
  }
}

variable "network_acl_bypass_for_azure_services" {
  type        = bool
  default     = false
  description = "(Optional) If Azure services can bypass ACLs. Defaults to false."
}

variable "network_acl_bypass_ids" {
  type        = list(string)
  default = null
  description = "(Optional) The list of resource Ids for Network Acl Bypass for this Cosmos DB account."
}

variable "local_authentication_disabled" {
  type        = bool
  default     = false
  description = "(Optional) Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Defaults to false. Can be set only when using the SQL API."
}

variable "analytical_storage" {
  type = object({
    schema_type = string
  })
  default     = null
  description = "(Required) The schema type of the Analytical Storage for this Cosmos DB account. Possible values are FullFidelity and WellDefined."
}

variable "capacity" {
  type = object({
    total_throughput_limit = number
  })
  default = {
    total_throughput_limit = 4000
  }
  description = "(Required) The total throughput limit imposed on this Cosmos DB account (RU/s). Possible values are at least -1. -1 means no limit."
}

variable "consistency_policy" {
  type = object({
    consistency_level       = string
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  nullable    = false
  description = <<EOT
  - 'consistency_level' - (Required) The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix.
  - 'max_interval_in_seconds' - (Optional) When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. The accepted range for this value is 5 - 86400 (1 day). Defaults to 5. Required when consistency_level is set to BoundedStaleness.
  - 'max_staleness_prefix' - (Optional) When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. The accepted range for this value is 10 – 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness.
  EOT
}

variable "geo_location" {
  type = set(object({
    failover_priority = optional(number)
    location          = optional(string)
    zone_redundant    = optional(bool)
  }))
  nullable    = false
  default = [{}]
  description = <<EOT
  - 'location' - (Required) The name of the Azure region to host replicated data.
  - 'failover_priority' - (Required) The failover priority of the region. A failover priority of 0 indicates a write region. The maximum value for a failover priority = (total number of regions - 1). Failover priority values must be unique for each of the regions in which the database account exists. Changing this causes the location to be re-provisioned and cannot be changed for the location with failover priority 0.
  - 'zone_redundant' - (Optional) Should zone redundancy be enabled for this region? Defaults to false.
  EOT
}

# Note:
# Setting MongoDBv3.4 also requires setting EnableMongo.
# Note:
# Only AllowSelfServeUpgradeToMongo36, DisableRateLimitingResponses, EnableAggregationPipeline, MongoDBv3.4, EnableMongoRetryableWrites,
# EnableMongoRoleBasedAccessControl, EnableUniqueCompoundNestedDocs, EnableMongo16MBDocumentSupport, mongoEnableDocLevelTTL, EnableTtlOnCustomPath and EnablePartialUniqueIndex can be added to an existing Cosmos DB account.
# Note:
# Only DisableRateLimitingResponses and EnableMongoRetryableWrites can be removed from an existing Cosmos DB account.
variable "capabilities" {
  type = set(object({
    name = string
  }))
  default     = null
  description = <<EOT
  - 'name' - (Required) The capability to enable - Possible values are AllowSelfServeUpgradeToMongo36, DisableRateLimitingResponses, EnableAggregationPipeline, EnableCassandra, EnableGremlin, EnableMongo, EnableMongo16MBDocumentSupport, EnableMongoRetryableWrites, EnableMongoRoleBasedAccessControl, EnablePartialUniqueIndex, EnableServerless, EnableTable, EnableTtlOnCustomPath, EnableUniqueCompoundNestedDocs, MongoDBv3.4 and mongoEnableDocLevelTTL.
  EOT
}

variable "virtual_network_rule" {
  type = set(object({
    id                                   = string
    ignore_missing_vnet_service_endpoint = optional(bool)
  }))
  default = null
  description = <<EOT
  - 'id' - (Required) The ID of the virtual network subnet.
  - 'ignore_missing_vnet_service_endpoint' - (Optional) If set to true, the specified subnet will be added as a virtual network rule even if its CosmosDB service endpoint is not active. Defaults to false.
  EOT
}

variable "backup" {
  type = object({
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    storage_redundancy  = optional(string)
    tier                = optional(string)
    type                = string
  })
  default = null
  description = <<EOT
  - 'type' - (Required) The type of the backup. Possible values are Continuous and Periodic. Migration of Periodic to Continuous is one-way, changing Continuous to Periodic forces a new resource to be created
  - 'tier' - (Optional) The continuous backup tier. Possible values are Continuous7Days and Continuous30Days.
  - 'interval_in_minutes' - (Optional) The interval in minutes between two backups. Possible values are between 60 and 1440. Defaults to 240.
  - 'retention_in_hours' - (Optional) The time in hours that each backup is retained. Possible values are between 8 and 720. Defaults to 8.
  - 'storage_redundancy' - (Optional) The storage redundancy is used to indicate the type of backup residency. Possible values are Geo, Local and Zone. Defaults to Geo.
  - NOTE: You can only configure interval_in_minutes, retention_in_hours and storage_redundancy when the type field is set to Periodic.
  EOT
}

variable "cors_rule" {
  type = object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = optional(number)
  })
  default = null
  description = <<EOT
  - 'allowed_headers' - (Required) A list of headers that are allowed to be a part of the cross-origin request.
  - 'allowed_methods' - (Required) A list of HTTP headers that are allowed to be executed by the origin. Valid options are DELETE, GET, HEAD, MERGE, POST, OPTIONS, PUT or PATCH.
  - 'allowed_origins' - (Required) A list of origin domains that will be allowed by CORS.
  - 'exposed_headers' - (Required) A list of response headers that are exposed to CORS clients.
  - 'max_age_in_seconds' - (Optional) The number of seconds the client should cache a preflight response. Possible values are between 1 and 2147483647.
  EOT
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for uai in var.managed_identities.user_assigned_resource_ids : can(regex("^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/resourceGroups/[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()-]{1}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/[a-zA-Z0-9-_]+$", uai))])
    error_message = "The user_assigned_resource_ids must be properly formatted e.g. /subscriptions/00f000ad-000a-40a0-b0e0-c00b00000a0b/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-identity"
  }
}

# Any database account with Continuous type (live account or accounts deleted in last 30 days) is a restorable database account and
# there cannot be Create/Update/Delete operations on the restorable database accounts.
# They can only be read and retrieved by azurerm_cosmosdb_restorable_database_accounts.
variable "restore" {
  type = object({
    restore_timestamp_in_utc   = string
    source_cosmosdb_account_id = string
    tables_to_restore          = optional(list(string))
    database = optional(set(object({
      collection_names = optional(set(string))
      name             = string
    })))
    gremlin_database = optional(list(object({
      graph_names = optional(list(string))
      name        = string
    })))
  })
  default = null
  description = <<EOT
  - 'source_cosmosdb_account_id' - (Required) The resource ID of the restorable database account from which the restore has to be initiated. The example is /subscriptions/{subscriptionId}/providers/Microsoft.DocumentDB/locations/{location}/restorableDatabaseAccounts/{restorableDatabaseAccountName}. Changing this forces a new resource to be created.
  - 'restore_timestamp_in_utc' - (Required) The creation time of the database or the collection (Datetime Format RFC 3339). Changing this forces a new resource to be created.
  - 'database' - (Optional) A database block as defined below. Changing this forces a new resource to be created.
  - 'gremlin_database' - (Optional) One or more gremlin_database blocks as defined below. Changing this forces a new resource to be created.
  - 'tables_to_restore' - (Optional) A list of specific tables available for restore. Changing this forces a new resource to be created.
  EOT
}

variable "cosmosdb_account_timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 180 minutes) Used when creating the CosmosDB Account.
 - `delete` - (Defaults to 180 minutes) Used when deleting the CosmosDB Account.
 - `read` - (Defaults to 5 minutes) Used when retrieving the CosmosDB Account.
 - `update` - (Defaults to 180 minutes) Used when updating the CosmosDB Account.
EOT
}


variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal. Examples: name: 'Contributor' or ID: '/subscriptions/\<sub_guid\>/providers/Microsoft.Authorization/roleDefinitions/\<role_guid\>'
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.
- `delegated_namaged_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION

  # role_assignments.role_definition_id_or_name
  validation {
    condition = alltrue([
      for role in var.role_assignments :
      role.role_definition_id_or_name != null ?
      can(regex("^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/providers/Microsoft.Authorization/roleDefinitions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", role.role_definition_id_or_name))
      ||
      !can(regex("Microsoft.Authorization/roleDefinitions", role.role_definition_id_or_name))
      &&
      can(regex("^.{1,512}$", role.role_definition_id_or_name))
      : false
    ])
    error_message = <<ERROR_MESSAGE
        role_definition_id_or_name must have the following format:
         - Using the role definition Id: /subscriptions/<sub_guid>/providers/Microsoft.Authorization/roleDefinitions/<role_guid>
         - Using the built-in role name: "Reader" | "Contributor" | "Storage Blob Data Contributor" https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
         - Custom role name can include letters, numbers, spaces, and special characters. Maximum number of characters is 512.
         - Custom role cannot include parts of role definition ID string e.g. Microsoft.Authorization/roleDefinitions
      ERROR_MESSAGE
  }

  # role_assignments.principal_id
  validation {
    condition = alltrue(
      [for role in var.role_assignments :
        can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", role.principal_id))
      ]
    )
    error_message = "The principal_id should have this format: 000220ef-0000-0000-9d00-a0f2f07f0000"
  }

  # role_assignments.condition_version
  validation {
    condition = alltrue([
      for v in var.role_assignments :
      v.condition != null && v.condition_version != null ?
      contains(["1.0", "2.0"], v.condition_version)
      : true
    ])
    error_message = "If condition and condition_version are set, condition_version must be 1.0 or 2.0"
  }

  # role_assignments.delegated_managed_identity_resource_id
  validation {
    condition = (
      var.role_assignments != null ?
      alltrue([
        for role in var.role_assignments :
        role.delegated_managed_identity_resource_id != null ?
        can(regex("^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/resourceGroups/[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()-]{1}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/[a-zA-Z0-9-_]+$", role.delegated_managed_identity_resource_id))
        : true
      ])
      : true
    )
    error_message = <<ERROR_MESSAGE
    The delegated_managed_identity_resource_id must be properly formatted.

  delegated_managed_identity_resource_id = "/subscriptions/00f000ad-000a-40a0-b0e0-c00b00000a0b/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-identity"
  ERROR_MESSAGE
  }
}

