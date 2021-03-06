# Private Bastion Terraform module for Google Cloud

This module implements a wrapper around Google's published bastion module that
allows it to function correctly when deployed in a private VPC without public
internet access, by pulling a container image containing a forward-proxy from a
Google Artifact or Container Registry.

As such, the scope of services this module provides is restricted to

* An IAP protected forward-proxy deployed from Container Registry or Artifact Registry
* An IAP protected SSH login
* An optional set of Firewall Rules to allow bastion to connect to other GCP
  resources specified as destination CIDRs, target service accounts, or target tags

> NOTE: This module is opinionated and deliberately inflexible; the Google
> [bastion-host](https://registry.terraform.io/modules/terraform-google-modules/bastion-host/google/latest)
> (and related submodules) make a much better general purpose bastion for GCP.

This module was born out of a repeated pattern of deployment; launch a bastion VM
with custom onboarding script to pull [tinyproxy](https://tinyproxy.github.io/)
from a source accessible to the VM.

A few iterations later, and now the module will launch a
[Container-Optimized OS](https://cloud.google.com/container-optimized-os/docs/concepts/features-and-benefits)
VM with a `cloud-init` declaration that pulls a `forward-proxy` container from
the private repo you specify. The Terraform will apply an appropriate IAM repo
reader role to the created bastion service account so it can automatically pull
the container as needed.

## Usage

1. Meet the prerequisites listed in [Prerequisites](#prerequisites) section

    The `forward-proxy` container must already exist in a private repo for which
    you have the ability to assign IAM roles.

2. Clone the [quick-start](examples/quick-start/) as a starting point.

    ```shell
    mkdir private-bastion
    cd private-bastion
    terraform init -from-module memes/private-bastion/google//examples/quick-start
    ```

3. Create a `terraform.tfvars` file

    Use the file to set the required parameters; see [Inputs](#inputs) for
    other optional values to set, and the [quick-start](examples/quick-start/README.md) documentation for more details.

    > NOTE: It is recommended to include `bastion_targets` to ensure GCP Firewall
    > rules are created to allow bastion => other resource traffic. Just add the
    > target tags, service accounts, or CIDRs to the input. If you leave
    > `bastion_targets` at the default value, you will need to create bastion to
    > resource firewall rules outside of this module.

    ```hcl
    prefix                = "example"
    project_id            = "my-project-id"
    zone                  = "us-west1-c"
    subnet                = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/my-subnet"

    # This needs to point to your private repo copy of forward-proxy
    proxy_container_image = "us-docker.pkg.dev/my-project-id/f5-automation-factory-container/forward-proxy:my-build"

    # Allow the bastion to connect to any VM tagged 'bastion-ok' and to the GKE
    # master nodes at 172.19.0.0/28
    bastion_targets       = {
        service_accounts = null
        cidrs            = ["172.19.0.0/28"]
        tags             = ["bastion-ok"]
        priority         = null
    }
    ```

4. Launch the VM

    ```shell
    terraform apply
    ```

5. Connect to the bastion

    The `gcloud` commands to connect to the bastion are included as Terraform
    outputs.

    1. SSH

        ```shell
        eval $(terraform output -raw ssh_command)
        ```

    2. HTTP/HTTPS tunnel

        ```shell
        eval $(terraform output -raw tunnel_command)
        ```

        While the tunnel is up and running, you can set your browser or tools to
        connect via the tunnel. For example, if you've have a GKE kubeconfig for a
        private cluster loaded:

        ```shell
        HTTPS_PROXY=127.0.0.1:8888 kubectl get pods
        ```

6. Teardown the bastion

    ```shell
    terraform destroy -auto-approve
    ```

### Prerequisites

A copy of the [forward-proxy](containers/forward-proxy/) container needs to be
created or copied to a suitable private repository. The instructions below use
a Cloud Build script to create the container and upload it to the private
repository. Of course, you can use `docker build` or `podman build` too, so long
as you have authenticated to the target repository.

> Alternatively, you can use the [container-stager](https://github.com/f5devcentral/terraform-google-f5-automation-factory/tree/main/archetype/container-stager)
> archetype published as part of F5 DevCentral's [Google Automation Factory](https://github.com/f5devcentral/terraform-google-f5-automation-factory/) to copy my public image
> from [Docker Hub](https://hub.docker.com/r/memes/forward-proxy) or [GitHub Container Registry](https://github.com/memes/terraform-google-private-bastion/pkgs/container/terraform-google-private-bastion%2Fforward-proxy) to your private container
> registry. [Google Automation Factory](https://github.com/f5devcentral/terraform-google-f5-automation-factory/)
> can also be used to create and manage a shared Artifact Repository with automatic
> update triggers.

1. Enable one of Artifact Registry API or Container Registry API,
    if needed, and create an registry as needed

    See the GCP documentation for [Artifact management](https://cloud.google.com/artifact-management/docs/overview)
    for more details.

    Make a note of the repo path for your repository. For example, the `US` located
    Artifact Repository `f5-automation-factory-container` deployed to project
    `my-gcp-project` will have repo `us-docker.pkg.dev/my-project-id/f5-automation-factory-container`

2. Review the source of the [forward-proxy](containers/forward-proxy/) container

    You wouldn't deploy an unverified source, would you? :)

    Make any required changes; if you think it'd be a good addition to the base
    image or experience a bug, please open an issue and/or PR against this repo.
    See [CONTRIBUTING](CONTRIBUTING.md) for more details.

3. Build the image and upload to your private repository

    Trigger a Cloud Build run from this source, giving the repo path and a custom
    tag.

    ```shell
    gcloud builds submit \
        --config cloudbuild.yml \
        --project my-project-id \
        --substitutions _CONTAINER_REGISTRY=us-docker.pkg.dev/my-project-id/f5-automation-factory-container,TAG_NAME=my-build
    ```

    Cloud Build will create the container, tag it with `latest` and `my-build`,
    and upload to your private registry.

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
| <a name="module_bastion"></a> [bastion](#module\_bastion) | terraform-google-modules/bastion-host/google | 5.0.0 |

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
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to use when naming resources managed by this module. Must be RFC1035<br>compliant and between 5 and 30 characters in length, inclusive. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the bastion instance will be deployed. | `string` | n/a | yes |
| <a name="input_proxy_container_image"></a> [proxy\_container\_image](#input\_proxy\_container\_image) | The qualified container image to use as a forward-proxy through this bastion.<br>You must supply this value with a valid private Artifact or Container Repository<br>identifier, or a public repo identifier. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The fully-qualified subnetwork self-link to which the bastion instance will be<br>attached. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The compute zone where where the bastion instance will be deployed. | `string` | n/a | yes |
| <a name="input_additional_ports"></a> [additional\_ports](#input\_additional\_ports) | A list of additional TCP ports that will be allowed to receive IAP tunneled<br>traffic. Default is [8888] to allow for forward-proxy use-case. | `list(number)` | <pre>[<br>  8888<br>]</pre> | no |
| <a name="input_bastion_targets"></a> [bastion\_targets](#input\_bastion\_targets) | An optional set of firewall targets that will be used to create GCP Firewall Rules<br>that allow the targets to receive _ALL_ ingress traffic from the bastion instance.<br>Targets are specified as a list of service account emails, destination CIDRs, and<br>target network tags. If a priority is unspecified, the rules will be created at<br>the default priority (1000).<br><br>Leave this variable at the default empty value to manage firewall rules outside<br>this module. | <pre>object({<br>    service_accounts = list(string)<br>    cidrs            = list(string)<br>    tags             = list(string)<br>    priority         = number<br>  })</pre> | <pre>{<br>  "cidrs": null,<br>  "priority": null,<br>  "service_accounts": null,<br>  "tags": null<br>}</pre> | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | The size of the bastion boot disk in GB. Default is 20. | `number` | `20` | no |
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | Boolean flag to toggle provisioning of an ephemeral public IP on the bastion<br>instance; default is false. | `bool` | `false` | no |
| <a name="input_image"></a> [image](#input\_image) | Specifies the image family and project id to use for bastion. Default will launch<br>the latest stable COS image with Confidential VM support. | <pre>object({<br>    family     = string<br>    project_id = string<br>  })</pre> | <pre>{<br>  "family": "cos-stable",<br>  "project_id": "confidential-vm-images"<br>}</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of labels to apply to resources created by this module, in addition<br>to those always set. Default is empty. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The Compute Engine machine type to use for bastion. Default is 'e2-medium'. | `string` | `"e2-medium"` | no |
| <a name="input_members"></a> [members](#input\_members) | An optional list of user/group/serviceAccount emails that will be added as IAP<br>members for _this_ bastion. Default is empty. | `list(string)` | `[]` | no |
| <a name="input_service_account_roles_supplemental"></a> [service\_account\_roles\_supplemental](#input\_service\_account\_roles\_supplemental) | An optional list of roles that will be assigned to the generated bastion service<br>account in addition to the standard logging, metrics, and OS Login roles. Default<br>is an empty list. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An optional list of network tags to apply to resources created by this module,<br>in addition to those always set. Default is empty. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The private IP address of the bastion instance. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | The self-link of the bastion instance. |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | A gcloud command that will SSH via IAP to bastion host. |
| <a name="output_tunnel_command"></a> [tunnel\_command](#output\_tunnel\_command) | A gcloud command that create a tunnel between localhost:8888 via IAP to bastion<br>host; connections to localhost:8888 will be tunneled to bastion forward-proxy. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
