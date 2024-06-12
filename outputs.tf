# output "private_endpoints" {
#   description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
#   value       = azurerm_private_endpoint.this
# }

# Module should include the full resource via a 'resource' output
# https://confluence.ei.leidos.com/display/ECM/Terraform+ECM+Style+Guide#TerraformECMStyleGuide-TFFR2-Category:Outputs-AdditionalTerraformOutputs
# output "resource" {
#   description = "This is the full output for the resource."
#   value       = a # TODO: Replace this dummy resource azurerm_resource_group.TODO with your module resource
# }
