terraform {
  required_version = ">= 0.14.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.8.0"
    }
  }
}

# Use service account impersonation if a service account email has been provided
provider "google" {
  impersonate_service_account = var.tf_service_account
}

module "bastion" {
  source                = "memes/private-bastion/google"
  version               = "2.2.0"
  proxy_container_image = var.proxy_container_image
  prefix                = var.prefix
  project_id            = var.project_id
  zone                  = var.zone
  subnet                = var.subnet
  labels                = var.labels
  tags                  = var.tags
  bastion_targets       = var.bastion_targets
}
