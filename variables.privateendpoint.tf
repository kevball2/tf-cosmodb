variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    lock = optional(object({
      name = optional(string, null)
      kind = optional(string, null)
    }), {})
    tags                                    = optional(map(any), null)
    subnet_resource_id                      = string
    subresource_name                        = list(string)
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    inherit_tags                            = optional(bool, false)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
      member_name = optional(string)
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on the resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - The service name of the private endpoint.  Possible value are `blob`, 'dfs', 'file', `queue`, `table`, and `web`.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_associations` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.
DESCRIPTION

  # private_endpoints.name
  validation {
    condition     = alltrue([for pe in var.private_endpoints : can(regex("^[a-zA-Z0-9-_]{2,64}$", pe.name))])
    error_message = <<ERROR_MESSAGE
      `private_endpoint.name`
      - Must be between 2 and 64 characters
      - Valid characters are Alphanumerics, underscores, periods, and hyphens.
      - Start with alphanumeric. End alphanumeric or underscore.
    ERROR_MESSAGE
  }

  # private_endpoints.role_assignments.role_definition_id_or_name
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.role_assignments != null ?
      alltrue([
        for role in pe.role_assignments :
        can(regex("^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/providers/Microsoft.Authorization/roleDefinitions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", role.role_definition_id_or_name))
        ||
        !can(regex("Microsoft.Authorization/roleDefinitions", role.role_definition_id_or_name))
        &&
        can(regex("^.{1,512}$", role.role_definition_id_or_name))
      ])
      : true
    ])
    error_message = <<ERROR_MESSAGE
        `role_definition_id_or_name` must have the following format:
         - Using the role definition Id: /subscriptions/<sub_guid>/providers/Microsoft.Authorization/roleDefinitions/<role_guid>
         - Using the built-in role name: "Reader" | "Contributor" | "Storage Blob Data Contributor" https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
         - Custom role name can include letters, numbers, spaces, and special characters. Maximum number of characters is 512.
         - Custom role cannot include parts of role definition ID string e.g. Microsoft.Authorization/roleDefinitions
      ERROR_MESSAGE
  }

  # private_endpoints.role_assignments.principal_id
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.role_assignments != null ?
      alltrue([
        for role in pe.role_assignments :
        can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", role.principal_id))
      ])
      : true
    ])
    error_message = "The principal_id should have this format: 000220ef-0000-0000-9d00-a0f2f07f0000"
  }

  # private_endpoints.role_assignments.condition version
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.role_assignments != null ?
      alltrue([
        for role in pe.role_assignments :
        role.condition != null && role.condition_version != null ?
        contains(["1.0", "2.0"], role.condition_version)
        : true
      ])
      : true
    ])
    error_message = "If condition and condition_version are set, condition_version must be 1.0 or 2.0"
  }

  # private_endpoints.lock.kind
  validation {
    condition = alltrue([
      for pe in var.private_endpoints : pe.lock.kind != null ?
      contains(["CanNotDelete", "ReadOnly"], pe.lock.kind)
      : true
    ])
    error_message = "The lock kind property must be either 'CanNotDelete' or 'ReadOnly' if it is not null."
  }

  # private_endpoints.lock.name
  validation {
    condition = alltrue([
      for pe in var.private_endpoints : pe.lock.name != null ?
      can(regex("^[a-zA-Z0-9._()-]{0,89}[a-zA-Z0-9_()-]{1}$", pe.lock.name))
      : true
    ])
    error_message = <<ERROR_MESSAGE
      The lock.name property has the following requirements.
        -Length of 1 to 90 characters
        -Alphanumerics, periods, underscores, hyphens, and parenthesis.
        -Can't end in period.
      ERROR_MESSAGE
  }

  # private_endpoints.subnet_resource_id
  validation {
    condition = alltrue(
      [for role in var.private_endpoints :
        role.subnet_resource_id != null ?
        can(regex("^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/resourceGroups/[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()]{1}/providers/Microsoft.Network/virtualNetworks/[a-zA-Z0-9_.-]{2,64}/[a-zA-Z0-9_.-]{1,80}", role.subnet_resource_id))
        : true
      ]
    )
    error_message = <<ERROR_MESSAGE
        `subnet_resource_id` must have the following format:
         - Alphanumerics, underscores, periods, and hyphens.
         - Start with alphanumeric. End alphanumeric or underscore.
         - Example: "/subscriptions/00f000ad-000a-40a0-b0e0-c00b00000a0b/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
      ERROR_MESSAGE
  }

  # private_endpoints.private_dns_zone_group_name
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.private_dns_zone_group_name != null ?
      can(regex("^[a-zA-Z0-9_.-]{1,80}$", pe.private_dns_zone_group_name))
      &&
      can(regex("^([a-zA-Z0-9]|[a-zA-Z0-9].*[a-zA-Z0-9_])$", pe.private_dns_zone_group_name))
      : true
    ])
    error_message = <<ERROR_MESSAGE
        `subnet_resource_id` must have the following format:
         - 1-80 characters in length
         - Alphanumerics, underscores, periods, and hyphens.
         - Start with alphanumeric. End alphanumeric or underscore.
      ERROR_MESSAGE
  }

  # private_endpoints.private_dns_zone_resource_ids
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.private_dns_zone_resource_ids != null ?
      alltrue([
        for id in tolist(pe.private_dns_zone_resource_ids) :
        can(regex("^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/resourceGroups/[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()]{1}/providers/Microsoft.Network/privateDnsZones/([a-zA-Z0-9_.-]+\\.core\\.usgovcloudapi\\.net$|[a-zA-Z0-9_.-]+\\.core\\.windows\\.net$|[a-zA-Z0-9_.-]+\\.azure\\.us$)", id))
      ])
      : true
    ])
    error_message = <<ERROR_MESSAGE
      `private_dns_zone_resource_ids` must have the following format:
      - 1-63 characters, 2 to 34 labels
      - Each label can contain alphanumerics, underscores, and hyphens.
      - Each label is separated by a period.
      - Example: "/subscriptions/00f000ad-000a-40a0-b0e0-c00b00000a0b/resourceGroups/rg-test/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.usgovcloudapi.net"
      - Note: Suffix for Gov: core.usgovcloudapi.net and Global: .core.windows.net
    ERROR_MESSAGE
  }

  # private_endpoints.application_security_group_associations
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.application_security_group_associations != null ?
      alltrue([
        for id in pe.application_security_group_associations :
        can(regex("^/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/resourceGroups/[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()]{1}/providers/Microsoft.Network/applicationSecurityGroups/[a-zA-Z0-9_.-]", id))
      ])
      : true
    ])
    error_message = <<ERROR_MESSAGE
      `application_security_group_associations.application_security_group_id` must have the following format:
      - /subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/applicationSecurityGroups/applicationSecurityGroupValue
    ERROR_MESSAGE
  }

  # private_endpoints.private_service_connection_name
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.private_service_connection_name != null ?
      can(regex("^[a-zA-Z0-9_.-]{2,64}$", pe.private_service_connection_name))
      &&
      can(regex("^([a-zA-Z0-9]|[a-zA-Z0-9].*[a-zA-Z0-9_])$", pe.private_service_connection_name))
      : true
    ])
    error_message = <<ERROR_MESSAGE
      `private_service_connection_name` must have the following format:
      - 2-64 Alphanumeric characters
      - Alphanumerics, underscores, periods, and hyphens.
      - Start with alphanumeric. End alphanumeric or underscore.
    ERROR_MESSAGE
  }

  # private_endpoints.network_interface_name
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.network_interface_name != null ?
      can(regex("^[a-zA-Z0-9_.-]{1,80}$", pe.network_interface_name))
      &&
      can(regex("^([a-zA-Z0-9]|[a-zA-Z0-9].*[a-zA-Z0-9_])$", pe.network_interface_name))
      : true
    ])
    error_message = <<ERROR_MESSAGE
      `network_interface_name` must have the following format:
      - 1-80 Alphanumeric characters
      - Alphanumerics, underscores, periods, and hyphens.
      - Start with alphanumeric. End alphanumeric or underscore.
    ERROR_MESSAGE
  }

  # private_endpoints.resource_group_name
  validation {
    condition = alltrue([
      for pe in var.private_endpoints :
      pe.resource_group_name != null ?
      can(regex("^[a-zA-Z0-9_().-]{0,89}[a-zA-Z0-9_()-]{1}$", pe.resource_group_name))
      : true
    ])
    error_message = <<ERROR_MESSAGE
    The resource group name must meet the following requirements:
    - Between 1 and 90 characters long.
    - Can only contain Alphanumerics, underscores, parentheses, hyphens, periods.
    - Cannot end in a period
    ERROR_MESSAGE
  }

}


/*
# In this example we only support one service, e.g. Key Vault.
# If your service has multiple private endpoint services, then expose the service name.

# This variable is used to determine if the private_dns_zone_group block should be included,
# or if it is to be managed externally, e.g. using Azure Policy.
# https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault/issues/32
# Alternatively you can use AzAPI, which does not have this issue.
*/
variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  nullable    = false
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
}
