# The PE resource when we are managing the private_dns_zone_group block:
resource "azurerm_private_endpoint" "this_managed_dns_zone_groups" {
  for_each                      = { for k, v in var.private_endpoints : k => v if var.private_endpoints_manage_dns_zone_group }
  name                          = each.value.name != null ? each.value.name : "pep-${var.name}"
  location                      = each.value.location != null ? each.value.location : var.location
  resource_group_name           = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags

  private_service_connection {
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = each.value.subresource_name # Map to the service name if there is a single service ["MYSERVICE"]. map to each.value.subresource_name if there are multiple services.
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_resource_ids) > 0 ? ["this"] : []

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      subresource_name   = each.value.subresource_name[0] # Map to the service name if there is a single service "MYSERVICE" # map to each.value.subresource_name if there are multiple services.
      member_name        = try(coalesce(ip_configuration.value.member_name, each.value.subresource_name[0]))  # Map to the service name if there is a single service "MYSERVICE" # map to each.value.subresource_name if there are multiple services.
      private_ip_address = ip_configuration.value.private_ip_address
    }
  }
}


# The PE resource when we are managing **not** the private_dns_zone_group block:
resource "azurerm_private_endpoint" "this_unmanaged_dns_zone_groups" {
  for_each                      = { for k, v in var.private_endpoints : k => v if !var.private_endpoints_manage_dns_zone_group }
  name                          = each.value.name != null ? each.value.name : "pep-${var.name}"
  location                      = each.value.location != null ? each.value.location : var.location
  resource_group_name           = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags

  private_service_connection {
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = each.value.subresource_name # Map to the service name if there is a single service ["MYSERVICE"]. map to each.value.subresource_name if there are multiple services.
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_resource_ids) > 0 ? ["this"] : []

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      subresource_name   = each.value.subresource_name # Map to the service name if there is a single service "MYSERVICE" # map to each.value.subresource_name if there are multiple services.
      member_name        = each.value.subresource_name # Map to the service name if there is a single service "MYSERVICE" # map to each.value.subresource_name if there are multiple services.
      private_ip_address = ip_configuration.value.private_ip_address
    }
  }
  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}
