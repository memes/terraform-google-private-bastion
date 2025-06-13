variable "name" {
  type     = string
  nullable = false
  validation {
    # This value drives multiple derivative resource names and id's; the maximum
    # length permitted is limited by service account to 30 chars.
    condition     = can(regex("^[a-z](?:[a-z0-9-]{4,28}[a-z0-9])$", var.name))
    error_message = "The name variable must be RFC1035 compliant and between 5 and 30 characters in length."
  }
  description = <<-EOD
The name to use when creating resources managed by this module. Must be RFC1035 compliant and between 5 and 30 characters in length, inclusive.
EOD
}

variable "project_id" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id variable must must be 6 to 30 lowercase letters, digits, or hyphens; it must start with a letter and cannot end with a hyphen."
  }
  description = <<-EOD
The GCP project identifier where the bastion instance will be deployed.
EOD
}

variable "zone" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z]{2,20}-[a-z]{4,20}[0-9]-[a-z]$", var.zone))
    error_message = "At compute engine zone must be specified, and each zone must be a valid GCE zone name."
  }
  description = <<-EOD
The compute zone where where the bastion instance will be deployed.
EOD
}

variable "subnet" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^(?:https://www\\.googleapis\\.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.subnet))
    error_message = "Subnet variable must contain a fully-qualified subnet self-link."
  }
  description = <<-EOD
The fully-qualified subnetwork self-link to which the bastion instance will be
attached.
EOD
}

variable "image" {
  type = object({
    family     = string
    project_id = string
  })
  nullable = false
  validation {
    condition     = coalesce(var.image.project_id, "unspecified") != "unspecified" && can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.image.project_id)) && coalesce(var.image.family, "unspecified") != "unspecified" && can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.image.family))
    error_message = "The image variable must contain a valid project_id and family name."

  }
  default = {
    family     = "cos-stable"
    project_id = "confidential-vm-images"
  }
  description = <<-EOD
Specifies the image family and project id to use for bastion. Default will launch
the latest stable COS image with Confidential VM support.
EOD
}

variable "external_ip" {
  type        = bool
  nullable    = false
  default     = false
  description = <<-EOD
Boolean flag to toggle provisioning of an ephemeral public IP on the bastion
instance; default is false.
EOD
}

variable "labels" {
  type = map(string)
  validation {
    # GCP resource labels must be lowercase alphanumeric, underscore or hyphen,
    # and the key must be <= 63 characters in length
    condition     = length(compact([for k, v in var.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v)) ? "x" : ""])) == length(keys(var.labels))
    error_message = "Each label key:value pair must match expectations."
  }
  default     = {}
  description = <<-EOD
  An optional map of labels to apply to resources created by this module. Default is empty.
  EOD
}

variable "tags" {
  type     = list(string)
  nullable = false
  validation {
    condition     = alltrue([for tag in var.tags : can(regex("^[a-z][a-z0-9-]{0,62}$", tag))])
    error_message = "Each tag entry has to be RFC1035 compliant."
  }
  default     = []
  description = <<-EOD
An optional list of network tags to apply to resources created by this module. Default is empty.
EOD
}

variable "proxy_container_image" {
  type        = string
  nullable    = false
  description = <<-EOD
The qualified container image to use as a forward-proxy through this bastion.
You must supply this value with a valid private Artifact or Container Repository
identifier, or a public repo identifier.
EOD
}

variable "bastion_targets" {
  type = object({
    service_accounts = list(string)
    cidrs            = list(string)
    priority         = number
  })
  nullable = false
  default = {
    service_accounts = null
    cidrs            = null
    priority         = null
  }
  description = <<-EOD
An optional set of firewall targets that will be used to create GCP Firewall Rules
that allow the targets to receive _ALL_ ingress traffic from the bastion instance.
Targets are specified as a list of service account emails and  destination CIDRs.
If a priority is unspecified, the rules will be created at the default priority (1000).

Leave this variable at the default empty value to manage firewall rules outside
this module.
EOD
}

variable "additional_ports" {
  type     = list(number)
  nullable = false
  validation {
    condition     = length(join("", [for port in var.additional_ports : port > 0 && port < 65536 && port == floor(port) ? "x" : ""])) == length(var.additional_ports)
    error_message = "Each additional_port must be an integer between 1 and 65535 inclusive."
  }
  default     = []
  description = <<-EOD
A list of additional TCP ports that will be allowed to receive IAP tunneled
traffic, in addition to the forward-proxy listener port (see `remote_port`) and SSH.
Default is an empty list.
EOD
}

variable "disk_size_gb" {
  type     = number
  nullable = false
  validation {
    condition     = tonumber(coalesce(var.disk_size_gb, "20")) >= 20
    error_message = "The disk_size_gb value must be empty or >= 20."
  }
  default     = 20
  description = <<-EOD
The size of the bastion boot disk in GB. Default is 20.
EOD
}

variable "machine_type" {
  type        = string
  nullable    = false
  default     = "e2-medium"
  description = <<-EOD
The Compute Engine machine type to use for bastion. Default is 'e2-medium'.
EOD
}

variable "members" {
  type        = list(string)
  nullable    = false
  default     = []
  description = <<-EOD
An optional list of user/group/serviceAccount emails that will be added as IAP
members for _this_ bastion. Default is empty.
EOD
}

variable "additional_bastion_roles" {
  type        = list(string)
  nullable    = false
  default     = []
  description = <<-EOD
An optional list of roles that will be assigned to the generated bastion service
account in addition to the standard logging, metrics, and OS Login roles. Default
is an empty list.
EOD
}

variable "remote_port" {
  type     = number
  nullable = false
  validation {
    condition     = var.remote_port > 0 && var.remote_port < 65536 && var.remote_port == floor(var.remote_port)
    error_message = "The remote_port value must be an integer between 1 and 65535 inclusive."
  }
  default     = 8888
  description = <<-EOD
The remote TCP port that the forward-proxy container will be listening on.
Default value is 8888.
EOD
}

variable "local_port" {
  type     = number
  nullable = false
  validation {
    condition     = var.local_port > 0 && var.local_port < 65536 && var.local_port == floor(var.local_port)
    error_message = "The local_port value must be an integer between 1 and 65535 inclusive."
  }
  default     = 8888
  description = <<-EOD
The local TCP port that will be embedded in the IAP tunnel command output. This
is the value to which HTTP/HTTPS proxies should use; e.g. HTTP_PROXY=http://localhost:LOCAL_PORT,
where LOCAL_PORT is the value of `local_port` variable. Default value is 8888.
EOD
}

variable "source_cidrs" {
  type     = list(string)
  nullable = false
  validation {
    condition     = alltrue([for cidr in var.source_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Each source_cidrs value must be a valid IPv4 or IPv6 CIDR."
  }
  default     = []
  description = <<-EOD
An optional list of CIDRs that will be permitted to access the bastion on ports 22, `remote_port` (default 8888), and
any listed in `additional_ports` directly via public IP when the `external_ip` flag is set to true. Default is an empty
list.
EOD
}
