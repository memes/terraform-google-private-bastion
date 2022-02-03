variable "prefix" {
  type = string
  validation {
    # This value drives multiple derivative resource names and id's; the maximum
    # length permitted is limited by service account to 30 chars.
    condition     = can(regex("^[a-z](?:[a-z0-9-]{4,28}[a-z0-9])$", var.prefix))
    error_message = "The prefix variable must be RFC1035 compliant and between 5 and 30 characters in length."
  }
  description = <<-EOD
The prefix to use when naming resources managed by this module. Must be RFC1035
compliant and between 5 and 30 characters in length, inclusive.
EOD
}

variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id variable must must be 6 to 30 lowercase letters, digits, or hyphens; it must start with a letter and cannot end with a hyphen."
  }
  description = <<-EOD
The GCP project identifier where the bastion instance will be deployed.
EOD
}

variable "zone" {
  type = string
  validation {
    condition     = can(regex("^[a-z]{2,20}-[a-z]{4,20}[0-9]-[a-z]$", var.zone))
    error_message = "At compute engine zone must be specified, and each zone must be a valid GCE zone name."
  }
  description = <<-EOD
The compute zone where where the bastion instance will be deployed.
EOD
}

variable "subnet" {
  type = string
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

variable "ephemeral_ip" {
  type        = bool
  default     = false
  description = <<-EOD
Boolean flag to toggle provisioning of an ephemeral public IP on the bastion
instance; default is false.
EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<-EOD
An optional map of labels to apply to resources created by this module, in addition
to thos always set. Default is empty.
EOD
}

variable "tags" {
  type        = list(string)
  default     = []
  description = <<-EOD
An optional list of network tags to apply to resources created by this module,
in addition to those always set. Default is empty.
EOD
}

variable "proxy_container_image" {
  type        = string
  description = <<-EOD
The qualified container image to use as a forward-proxy through this bastion.
You must supply this value with a valid private Artifact or Container Respository
identifier, or a public repo identifier.
EOD
}

variable "bastion_targets" {
  type = object({
    service_accounts = list(string)
    cidrs            = list(string)
    tags             = list(string)
    priority         = number
  })
  default = {
    service_accounts = null
    cidrs            = null
    tags             = null
    priority         = null
  }
  description = <<-EOD
An optional set of firewall targets that will be used to create GCP Firewall Rules
that allow the targets to receive *ALL* ingress traffic from the bastion instance.
Targets are specified as a list of service account emails, destination CIDRs, and
target network tags. If a priority is unspecified, the rules will be created at
the default priority (1000).

Leave this variable at the default empty value to manage firewall rules outside
this module.
EOD
}

variable "additional_ports" {
  type = list(number)
  validation {
    condition     = length(join("", [for port in var.additional_ports : port > 0 && port < 65536 && port == floor(port) ? "x" : ""])) == length(var.additional_ports)
    error_message = "Each additional_port must be an integer between 1 and 65535 inclusive."
  }
  default = [
    8888,
  ]
  description = <<-EOD
A list of additional TCP ports that will be allowed to receive IAP tunneled
traffic. Default is [8888] to allow for forward-proxy use-case.
EOD
}

variable "disk_size_gb" {
  type = number
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
  default     = "e2-medium"
  description = <<-EOD
The Compute Engine machine type to use for bastion. Default is 'e2-medium'.
EOD
}

variable "members" {
  type        = list(string)
  default     = []
  description = <<-EOD
An optional list of user/group/serviceAccount emails that will be added as IAP
members for *this* bastion. Default is empty.
EOD
}

variable "service_account_roles_supplemental" {
  type        = list(string)
  default     = []
  description = <<-EOD
An optional list of roles that will be assigned to the generated bastion service
account in addition to the standard logging, metrics, and OS Login roles. Default
is an empty list.
EOD
}
