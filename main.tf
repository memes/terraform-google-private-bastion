terraform {
  required_version = ">= 0.14.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.8.0"
    }
  }
}

locals {
  bastion_name = format("%s-bastion", var.prefix)
  labels = merge(var.labels, {
    purpose = "iap-private-bastion"
    source  = "github-com-memes-terraform-google-private-bastion"
  })
  tags = distinct(concat(var.tags, [local.bastion_name]))
  gcr_repos = can(regex("^(?:(?:us|eu|asia)\\.)?gcr\\.io", var.proxy_container_image)) ? { repo = {
    location   = can(regex("^(?:us|eu|asia)\\.gcr.io", var.proxy_container_image)) ? regex("^(us|eu|asia)\\.gcr.io", var.proxy_container_image)[0] : null
    project_id = regex("^(?:(?:us|eu|asia)\\.)?gcr\\.io/([^/]+)", var.proxy_container_image)[0]
  } } : {}
  ar_repos = can(regex("^[a-z]{2,}(?:-[a-z]+[0-9])?-docker.pkg.dev", var.proxy_container_image)) ? { repo = {
    location   = regex("^([a-z]{2,}(?:-[a-z]+[0-9])?)-docker.pkg.dev", var.proxy_container_image)[0]
    project_id = split("/", var.proxy_container_image)[1]
    repository = split("/", var.proxy_container_image)[2]
  } } : {}
}

data "google_compute_subnetwork" "subnet" {
  self_link = var.subnet
}

module "bastion" {
  source                     = "terraform-google-modules/bastion-host/google"
  version                    = "5.2.0"
  service_account_name       = local.bastion_name
  name                       = local.bastion_name
  name_prefix                = local.bastion_name
  fw_name_allow_ssh_from_iap = format("%s-allow-iap-bastion", var.prefix)
  additional_ports           = concat([var.remote_port], var.additional_ports)
  project                    = var.project_id
  network                    = data.google_compute_subnetwork.subnet.network
  subnet                     = data.google_compute_subnetwork.subnet.self_link
  zone                       = var.zone
  image_family               = var.image.family
  image_project              = var.image.project_id
  labels                     = local.labels
  tags                       = local.tags
  external_ip                = var.external_ip
  metadata = {
    user-data = templatefile("${path.module}/templates/cloud-config.yaml", {
      docker_credential_registries = distinct(concat(
        [for repo in local.gcr_repos : repo.location != null ? format("%s.gcr.io", repo.location) : "gcr.io"],
        [for repo in local.ar_repos : format("%s-docker.pkg.dev", repo.location)]
      ))
      proxy_container_image = var.proxy_container_image
      proxy_port            = var.remote_port
    })
  }
  disk_size_gb                       = var.disk_size_gb
  machine_type                       = var.machine_type
  members                            = var.members
  service_account_roles_supplemental = var.service_account_roles_supplemental
}

# Allow the bastion to access packages from container registry
resource "google_storage_bucket_iam_member" "bastion" {
  for_each = local.gcr_repos
  bucket   = format("%sartifacts.%s.appspot.com", coalesce(each.value.location, "unspecified") != "unspecified" ? format("%s.", each.value.location) : "", each.value.project_id)
  role     = "roles/storage.objectViewer"
  member   = format("serviceAccount:%s", module.bastion.service_account)
  depends_on = [
    module.bastion,
  ]
}

# Allow the bastion to access packages from artifact registry
resource "google_artifact_registry_repository_iam_member" "bastion" {
  for_each   = local.ar_repos
  provider   = google-beta
  project    = each.value.project_id
  location   = each.value.location
  repository = each.value.repository
  role       = "roles/artifactregistry.reader"
  member     = format("serviceAccount:%s", module.bastion.service_account)
  depends_on = [
    module.bastion,
  ]
}

# Allow bastion instance to ping and connect to any port exposed on VMs executing
# as the specified service account(s).
resource "google_compute_firewall" "bastion_service_accounts" {
  count       = length(flatten([for sa in coalescelist(var.bastion_targets.service_accounts, ["unspecified"]) : sa if sa != "unspecified"])) > 0 ? 1 : 0
  project     = var.project_id
  name        = format("%s-allow-bastion-sa", var.prefix)
  network     = data.google_compute_subnetwork.subnet.network
  description = format("Allow bastion to reach specified target service accounts (%s)", var.prefix)
  direction   = "INGRESS"
  priority    = var.bastion_targets.priority
  source_service_accounts = [
    module.bastion.service_account,
  ]
  target_service_accounts = distinct(var.bastion_targets.service_accounts)
  allow {
    protocol = "all"
  }
  depends_on = [
    module.bastion,
  ]
}

# Allow bastion instance to ping and connect to any port exposed on VMs executing
# in the specified CIDRs.
resource "google_compute_firewall" "bastion_cidrs" {
  count       = length(flatten([for cidr in coalescelist(var.bastion_targets.cidrs, ["unspecified"]) : cidr if cidr != "unspecified"])) > 0 ? 1 : 0
  project     = var.project_id
  name        = format("%s-allow-bastion-cidrs", var.prefix)
  network     = data.google_compute_subnetwork.subnet.network
  description = format("Allow bastion to reach specified target CIDRs (%s)", var.prefix)
  direction   = "INGRESS"
  priority    = var.bastion_targets.priority
  source_service_accounts = [
    module.bastion.service_account,
  ]
  destination_ranges = distinct(var.bastion_targets.cidrs)
  allow {
    protocol = "all"
  }
  depends_on = [
    module.bastion,
  ]
}

# Allow bastion instance to ping and connect to any port exposed on VMs executing
# with the specified network tags.
resource "google_compute_firewall" "bastion_tags" {
  count       = length(flatten([for tag in coalescelist(var.bastion_targets.tags, ["***"]) : tag if tag != "***"])) > 0 ? 1 : 0
  project     = var.project_id
  name        = format("%s-allow-bastion-tags", var.prefix)
  network     = data.google_compute_subnetwork.subnet.network
  description = format("Allow bastion to reach specified target tags (%s)", var.prefix)
  direction   = "INGRESS"
  source_tags = [
    local.bastion_name,
  ]
  target_tags = distinct(var.bastion_targets.tags)
  allow {
    protocol = "all"
  }
  depends_on = [
    module.bastion,
  ]
}
