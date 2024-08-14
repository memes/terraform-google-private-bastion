terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

module "bastion" {
  source                = "memes/private-bastion/google"
  version               = "3.1.0"
  proxy_container_image = var.proxy_container_image
  name                  = var.name
  project_id            = var.project_id
  zone                  = var.zone
  subnet                = var.subnet
  labels                = var.labels
  tags                  = var.tags
  external_ip           = false
  bastion_targets       = var.bastion_targets
}
