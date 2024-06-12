# Specifies the location of the resource group.
variable "location" {
  type        = string
  default     = "usgovvirginia"
  description = <<DESCRIPTION
This variable defines the Azure region where the resource group will be created.
The default value is "usgovvirginia".
DESCRIPTION
}
