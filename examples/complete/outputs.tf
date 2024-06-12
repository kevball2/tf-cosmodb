output "TODO_resource" {
  description = "This is the full output for the resource."
  value       = module.complete.TODO
}

output "TODO_resource_id" {
  description = "The resource id of the TODO."
  value       = module.complete.TODO
}

output "TODO_name" {
  description = "The name of the TODO."
  value       = module.complete.TODO
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}
