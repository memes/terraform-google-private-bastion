terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

locals {
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

data "google_compute_image" "disk" {
  project = var.image.project_id
  family  = var.image.family
}

# Create the service account that will be used by the bastion
resource "google_service_account" "bastion" {
  project      = var.project_id
  account_id   = var.name
  display_name = "IAP bastion service account"
}

# Project roles to assign to the bastion service account
resource "google_project_iam_member" "bastion" {
  for_each = toset(concat([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.osLogin",
  ], var.additional_bastion_roles))
  project = var.project_id
  role    = each.key
  member  = google_service_account.bastion.member
}

# Allow listed members access to bastion service account
resource "google_service_account_iam_binding" "members" {
  service_account_id = google_service_account.bastion.id
  role               = "roles/iam.serviceAccountUser"
  members            = var.members
}

# Launch an instance to be the bastion.
resource "google_compute_instance" "bastion" {
  project      = var.project_id
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  labels       = var.labels

  service_account {
    email = google_service_account.bastion.email
    scopes = [
      "cloud-platform",
    ]
  }

  boot_disk {
    initialize_params {
      image  = data.google_compute_image.disk.self_link
      size   = var.disk_size_gb
      type   = "pd-standard"
      labels = var.labels
    }
  }

  tags = var.tags
  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    dynamic "access_config" {
      for_each = var.external_ip ? [1] : []
      content {}
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
    user-data = templatefile("${path.module}/templates/cloud-config.yaml", {
      docker_credential_registries = distinct(concat(
        [for repo in local.gcr_repos : repo.location != null ? format("%s.gcr.io", repo.location) : "gcr.io"],
        [for repo in local.ar_repos : format("%s-docker.pkg.dev", repo.location)]
      ))
      proxy_container_image = var.proxy_container_image
      proxy_port            = var.remote_port
    })
  }
}

# Allow all member accounts to use IAP access to bastion instance.
resource "google_iap_tunnel_instance_iam_binding" "members" {
  project  = google_compute_instance.bastion.project
  zone     = google_compute_instance.bastion.zone
  instance = google_compute_instance.bastion.name
  role     = "roles/iap.tunnelResourceAccessor"
  members  = var.members
}

# Allow the bastion to access packages from container registry
resource "google_storage_bucket_iam_member" "bastion" {
  for_each = local.gcr_repos
  bucket   = format("%sartifacts.%s.appspot.com", coalesce(each.value.location, "unspecified") != "unspecified" ? format("%s.", each.value.location) : "", each.value.project_id)
  role     = "roles/storage.objectViewer"
  member   = google_service_account.bastion.member
}

# Allow the bastion to access packages from artifact registry
resource "google_artifact_registry_repository_iam_member" "bastion" {
  for_each   = local.ar_repos
  project    = each.value.project_id
  location   = each.value.location
  repository = each.value.repository
  role       = "roles/artifactregistry.reader"
  member     = google_service_account.bastion.member
}

# Allow IAP access to the bastion instance.
resource "google_compute_firewall" "iap" {
  project     = var.project_id
  name        = format("%s-allow-iap-bastion", var.name)
  network     = data.google_compute_subnetwork.subnet.network
  description = format("Allow IAP ingress to bastion instances (%s)", var.name)
  direction   = "INGRESS"
  priority    = 900
  source_ranges = [
    "35.235.240.0/20",
  ]
  target_service_accounts = [
    google_service_account.bastion.email,
  ]
  allow {
    protocol = "tcp"
    ports    = concat([22], [var.remote_port], var.additional_ports)
  }
}

# Allow bastion instance to ping and connect to any port exposed on VMs executing
# as the specified service account(s).
resource "google_compute_firewall" "bastion_service_accounts" {
  count       = length(flatten([for sa in coalescelist(var.bastion_targets.service_accounts, ["unspecified"]) : sa if sa != "unspecified"])) > 0 ? 1 : 0
  project     = var.project_id
  name        = format("%s-allow-bastion-sa", var.name)
  network     = data.google_compute_subnetwork.subnet.network
  description = format("Allow bastion to reach specified target service accounts (%s)", var.name)
  direction   = "INGRESS"
  priority    = var.bastion_targets.priority
  source_service_accounts = [
    google_service_account.bastion.email,
  ]
  target_service_accounts = distinct(var.bastion_targets.service_accounts)
  allow {
    protocol = "all"
  }
}

# Allow bastion instance to ping and connect to any port exposed on VMs executing
# in the specified CIDRs.
resource "google_compute_firewall" "bastion_cidrs" {
  count       = length(flatten([for cidr in coalescelist(var.bastion_targets.cidrs, ["unspecified"]) : cidr if cidr != "unspecified"])) > 0 ? 1 : 0
  project     = var.project_id
  name        = format("%s-allow-bastion-cidrs", var.name)
  network     = data.google_compute_subnetwork.subnet.network
  description = format("Allow bastion to reach specified target CIDRs (%s)", var.name)
  direction   = "INGRESS"
  priority    = var.bastion_targets.priority
  source_service_accounts = [
    google_service_account.bastion.email,
  ]
  destination_ranges = distinct(var.bastion_targets.cidrs)
  allow {
    protocol = "all"
  }
}

# Allow access to the bastion instance on ports 22 and remote_port from the set of source CIDRs.
resource "google_compute_firewall" "access_bastion" {
  for_each      = var.external_ip && try(length(var.source_cidrs), 0) > 0 ? { format("%s-allow-public-ingress", var.name) = distinct(var.source_cidrs) } : {}
  project       = var.project_id
  name          = each.key
  network       = data.google_compute_subnetwork.subnet.network
  description   = format("Allow external access to public bastion (%s)", var.name)
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = each.value
  target_service_accounts = [
    google_service_account.bastion.email,
  ]
  allow {
    protocol = "TCP"
    ports = [
      22,
      var.remote_port,
    ]
  }
}
