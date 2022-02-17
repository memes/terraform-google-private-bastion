# Common variables
variable "tf_service_account" {
  type        = string
  default     = null
  description = <<-EOD
An optional service account email that the Google provider will be configured to
impersonate.
EOD
}

variable "prefix" {
  type        = string
  default     = "example-public-repo"
  description = <<-EOD
The prefix to use when naming resources managed by this module. Must be RFC1035
compliant and between 5 and 29 characters in length, inclusive.
EOD
}

variable "project_id" {
  type        = string
  description = <<-EOD
The GCP project identifier where the bastion instance will be deployed.
EOD
}

variable "zone" {
  type        = string
  description = <<-EOD
The compute zone where where the bastion instance will be deployed.
EOD
}

variable "subnet" {
  type        = string
  description = <<-EOD
The fully-qualified subnetwork self-link to which the bastion instance will be
attached.
EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<-EOD
An optional map of labels to apply to resources created by this module, in addition
to those always set. Default is empty.
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
that allow the targets to receive _ALL_ ingress traffic from the bastion instance.
Targets are specified as a list of service account emails, destination CIDRs, and
target network tags. If a priority is unspecified, the rules will be created at
the default priority (1000).

Leave this variable at the default empty value to manage firewall rules outside
this module.
EOD
}
