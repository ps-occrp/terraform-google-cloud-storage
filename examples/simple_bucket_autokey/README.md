# Simple Example

This example illustrates how to use the `simple-bucket` submodule.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| folder\_id | The folder where project is created | `string` | n/a | yes |
| key\_project\_id | The project where autokey is setup | `string` | n/a | yes |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
