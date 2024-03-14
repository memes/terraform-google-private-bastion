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
  version               = "3.0.0"
  proxy_container_image = var.proxy_container_image
  name                  = var.name
  project_id            = var.project_id
  zone                  = var.zone
  subnet                = var.subnet
  labels                = var.labels
  tags                  = var.tags
  external_ip           = true
  bastion_targets = {
    service_accounts = ["f5-bigip-welcome-mollusk@f5-gcs-4138-sales-cloud-sales.iam.gserviceaccount.com"]
    cidrs            = null
    priority         = null
  }
}
