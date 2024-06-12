# TODO: insert locals here.
locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

#   containers = { for container in flatten([
#     for db_name, db_config in var.sql_databases :
#     [
#       for container_name, container_config in db_config.containers :
#       {
#         name          = container_config.name
#         database_name = db_config.name
#         partition_key_path = container_config.partition_key_path
#         unique_key = container_config.unique_key
#         partition_key_version = container_config.partition_key_version
#         default_ttl = container_config.default_ttl
#         analytical_storage_ttl = container_config.analytical_storage_ttl
#         throughput = container_config.throughput
#         autoscale_settings = container_config.autoscale_settings
#       }
#     ]
# ]) : "${container.db_name}-${container.container_name}" => container }

containers = { for container in flatten([
    for db_name, db_config in var.sql_databases :
    [
      for container_name, container_config in db_config.containers :
      {
        name          = container_config.name
        database_name = db_config.name
        partition_key_path = container_config.partition_key_path
        unique_key = container_config.unique_key
        partition_key_version = container_config.partition_key_version
        default_ttl = container_config.default_ttl
        analytical_storage_ttl = container_config.analytical_storage_ttl
        throughput = container_config.throughput
        autoscale_settings = container_config.autoscale_settings
        indexing_policy = container_config.indexing_policy
        timeouts = container_config.timeouts
        conflict_resolution_policy = container_config.conflict_resolution_policy
      }
    ]
]) : "${container.database_name}-${container.name}" => container
 }




ip_range_filter = (var.allow_azure_portal_access == true ? contains(["usgov"],var.location) ?
                    "52.244.48.71,${var.ip_range_filter}" : "52.244.48.71,52.176.6.30,52.169.50.45,52.187.184.26,52.247.163.6,52.244.134.181,${var.ip_range_filter}" : var.ip_range_filter)


  # Private endpoint application security group associations
  # Remove if this resource does not support private endpoints

  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }



}





# 52.244.48.71"
# 52.247.163.6"
# 52.244.134.181
# 140.162.13.171


# 104.42.195.92"
# 40.76.54.131"
# 52.176.6.30"
# 52.169.50.45"
# 52.187.184.26"
# 13.88.56.148"
# 40.91.218.243"
# 13.91.105.215"
# 4.210.172.107"
