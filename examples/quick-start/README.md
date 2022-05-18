# Quick-start example

1. Meet the prerequisites listed in [Prerequisites](../../README.md#prerequisites) section

    The `forward-proxy` container must already exist in a private repo for which
    you have the ability to assign IAM roles.

2. Make a copy of these files

    Terraform can initialize from a repo subdirectory

    ```shell
    mkdir private-bastion
    cd private-bastion
    terraform init -from-module memes/private-bastion/google//examples/quick-start
    ```

    or you can copy the files, or work in this folder.

3. Create a `terraform.tfvars` file

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

## Private bastion and isolated VPCs

Even though the VM will be pulling from your private repository hosted in GCP,
by default Google Cloud resolves API calls to the _public IP addresses_ of the
Artifact Registry (or Container Registry). To allow the bastion VM to resolve
GCP API endpoints to a private address, you will need to enable Restricted API
access and configure private DNS resolution.

See [Configuring Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access) for more details.

## Using a public repo

This defeats the purpose of the private bastion, but may help when debugging any
access issues. If the bastion module is called with `ephemeral_ip` set to `true`,
an ephemeral public IP address will be created on the bastion VM, allowing it
to pull from a public repo outside of GCP.

For example, to pull from GitHub using a public IP address on the bastion:

```hcl
module "bastion" {
    source                = "memes/private-bastion/google"
    version               = "1.0.0"
    ephemeral_ip          = true
    proxy_container_image = "ghcr.io/memes/terraform-google-private-bastion/forward-proxy:v1.0.0"
    # Other fields remain the same
    prefix                = var.prefix
    project_id            = var.project_id
    zone                  = var.zone
    subnet                = var.subnet
    labels                = var.labels
    tags                  = var.tags
    bastion_targets       = var.bastion_targets
}
```

Of course, if there is a NAT gateway on the VPC network, or other NAT egress
solution such as BIG-IP, as long as the VPC routes have a default that directs
external traffic through the NAT then a pull from Docker Hub or GHCR will work.

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
| <a name="module_bastion"></a> [bastion](#module\_bastion) | memes/private-bastion/google | 2.0.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the bastion instance will be deployed. | `string` | n/a | yes |
| <a name="input_proxy_container_image"></a> [proxy\_container\_image](#input\_proxy\_container\_image) | The qualified container image to use as a forward-proxy through this bastion. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The fully-qualified subnetwork self-link to which the bastion instance will be<br>attached. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The compute zone where where the bastion instance will be deployed. | `string` | n/a | yes |
| <a name="input_bastion_targets"></a> [bastion\_targets](#input\_bastion\_targets) | An optional set of firewall targets that will be used to create GCP Firewall Rules<br>that allow the targets to receive _ALL_ ingress traffic from the bastion instance.<br>Targets are specified as a list of service account emails, destination CIDRs, and<br>target network tags. If a priority is unspecified, the rules will be created at<br>the default priority (1000).<br><br>Leave this variable at the default empty value to manage firewall rules outside<br>this module. | <pre>object({<br>    service_accounts = list(string)<br>    cidrs            = list(string)<br>    tags             = list(string)<br>    priority         = number<br>  })</pre> | <pre>{<br>  "cidrs": null,<br>  "priority": null,<br>  "service_accounts": null,<br>  "tags": null<br>}</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of labels to apply to resources created by this module, in addition<br>to those always set. Default is empty. | `map(string)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to use when naming resources managed by this module. Must be RFC1035<br>compliant and between 5 and 29 characters in length, inclusive. | `string` | `"example-public-repo"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An optional list of network tags to apply to resources created by this module,<br>in addition to those always set. Default is empty. | `list(string)` | `[]` | no |
| <a name="input_tf_service_account"></a> [tf\_service\_account](#input\_tf\_service\_account) | An optional service account email that the Google provider will be configured to<br>impersonate. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The private IP address of the bastion instance. |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | A gcloud command that will SSH via IAP to bastion host. |
| <a name="output_tunnel_command"></a> [tunnel\_command](#output\_tunnel\_command) | A gcloud command that create a tunnel between localhost:8888 via IAP to bastion<br>host; connections to localhost:8888 will be tunneled to bastion forward-proxy. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
