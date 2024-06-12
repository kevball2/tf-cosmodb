# Azure ECM Terraform Module

The Azure ECM Terraform module is a template repository to help developers create their own Terraform Module.

You can learn more about the development process on the [ECM Terraform Page](https://confluence.ei.leidos.com/display/ECM/HashiCorp+Terraform)

Enjoy it by following steps:

1. Use [this template](https://gitlab.leidos.com/hs/terraform-modules/terraform-azure-ecm-module-template) to create your repository.
2. Read [ECM Terraform Style Guide](https://confluence.ei.leidos.com/display/ECM/Terraform+ECM+Style+Guide)
5. Write Terraform code in a new branch.
8. Create a merge request for the main branch.
    * CI mr-check will be executed automatically.
    * Once mr-check was passed, with manually approval, the e2e test and version upgrade test would be executed.
9. Merge pull request.
10. Enjoy it!

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version |
|---------------------------------------------------------------------------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1  |
| <a name="requirement_null"></a> [null](#requirement\_null)                | >= 3.1  |

## Providers

| Name                                                 | Version |
|------------------------------------------------------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.1  |

## Modules

No modules.

## Resources

| Name                                                                                                       | Type     |
|------------------------------------------------------------------------------------------------------------|----------|
| [null_resource.nop](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name                                                            | Description      | Type     | Default | Required |
|-----------------------------------------------------------------|------------------|----------|---------|:--------:|
| <a name="input_echo_text"></a> [echo\_text](#input\_echo\_text) | The text to echo | `string` | n/a     |   yes    |

## Outputs

| Name                                                              | Description      |
|-------------------------------------------------------------------|------------------|
| <a name="output_echo_text"></a> [echo\_text](#output\_echo\_text) | The text to echo |
<!-- END_TF_DOCS -->
