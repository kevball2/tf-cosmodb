# below is here for reference to rework and nest containers
variable "sql_databases" {
  type = map(object({
    name                = string
    resource_group_name = string
    account_name        = string
    throughput          = optional(number, null)
    autoscale_settings = optional(object({
      max_throughput = optional(number, null)
    }), null)
    timeouts =  optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }), null)
    containers = optional(map(object({
      name               = string
      #database_name      = string
      partition_key_path = string
      unique_key = optional(object({
        paths = list(string)
      }), null)
      partition_key_version  = optional(number, null)
      default_ttl            = optional(number, null)
      analytical_storage_ttl = optional(number, null)

      throughput = optional(number, null)
      autoscale_settings = optional(object({
        max_throughput = optional(number, null)
        unique_key = set(object({
          paths = set(string)
        }))
      }), null)
      indexing_policy = optional(object({
        indexing_mode = optional(string)
        composite_index = optional(list(object({
          index = list(object({
            order = string
            path  = string
          }))
        })))
        excluded_path = optional(list(object({
          path = string
        })))
        included_path = optional(list(object({
          path = string
        })))
        spatial_index = optional(list(object({
          path = string
        })))
      }), null)
      timeouts =  optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }), null)
      conflict_resolution_policy = optional(object({
        conflict_resolution_path      = optional(string)
        conflict_resolution_procedure = optional(string)
        mode                          = string
      }), null)
    })), {})
  }))
  default = {}
}





