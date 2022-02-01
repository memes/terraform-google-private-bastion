# Private Bastion Terraform module for Google Cloud

This module implements a wrapper around Google's published bastion module that
allows it to function correctly when deployed in a private VPC without public
internet access, by pulling a Docker image from a Google Artifact or Container
Registry.

<!-- markdownlint-disable no-inline-html no-bare-urls -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | terraform-google-modules/bastion-host/google | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_artifact_registry_repository_iam_member.bastion](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_artifact_registry_repository_iam_member) | resource |
| [google_compute_firewall.bastion_cidrs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.bastion_service_accounts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.bastion_tags](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_storage_bucket_iam_member.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to use when naming resources managed by this module. Must be RFC1035<br>compliant and between 5 and 29 characters in length, inclusive. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the bastion instance will be deployed. | `string` | n/a | yes |
| <a name="input_proxy_container_image"></a> [proxy\_container\_image](#input\_proxy\_container\_image) | The qualified container image to use as a forward-proxy through this bastion.<br>You must supply this value with a valid private Artifact or Container Respository<br>identifier, or a public repo identifier. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The fully-qualified subnetwork self-link to which the bastion instance will be<br>attached. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The compute zone where where the bastion instance will be deployed. | `string` | n/a | yes |
| <a name="input_bastion_targets"></a> [bastion\_targets](#input\_bastion\_targets) | An optional set of firewall targets that will be used to create GCP Firewall Rules<br>that allow the targets to receive *ALL* ingress traffic from the bastion instance.<br>Targets are specified as a list of service account emails, destination CIDRs, and<br>target network tags. If a priority is unspecified, the rules will be created at<br>the default priority (1000).<br><br>Leave this variable at the default empty value to manage firewall rules outside<br>this module. | <pre>object({<br>    service_accounts = list(string)<br>    cidrs            = list(string)<br>    tags             = list(string)<br>    priority         = number<br>  })</pre> | <pre>{<br>  "cidrs": null,<br>  "priority": null,<br>  "service_accounts": null,<br>  "tags": null<br>}</pre> | no |
| <a name="input_ephemeral_ip"></a> [ephemeral\_ip](#input\_ephemeral\_ip) | Boolean flag to toggle provisioning of an ephemeral public IP on the bastion<br>instance; default is false. | `bool` | `false` | no |
| <a name="input_image"></a> [image](#input\_image) | Specifies the image family and project id to use for bastion. Default will launch<br>the latest stable COS image with Confidential VM support. | <pre>object({<br>    family     = string<br>    project_id = string<br>  })</pre> | <pre>{<br>  "family": "cos-stable",<br>  "project_id": "confidential-vm-images"<br>}</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of labels to apply to resources created by this module, in addition<br>to thos always set. Default is empty. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An optional list of network tags to apply to resources created by this module,<br>in addition to those always set. Default is empty. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | A gcloud command that will SSH via IAP to bastion host. |
| <a name="output_tunnel_command"></a> [tunnel\_command](#output\_tunnel\_command) | A gcloud command that create a tunnel between localhost:8888 via IAP to bastion<br>host; connections to localhost:8888 will be tunneled to bastion forward-proxy. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
