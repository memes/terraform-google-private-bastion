output "ssh_command" {
  value       = format("gcloud compute ssh %s --tunnel-through-iap --strict-host-key-checking=no --ssh-flag=-oUserKnownHostsFile=/dev/null --ssh-flag=-A --project=%s --zone=%s", module.bastion.hostname, var.project_id, var.zone)
  description = <<-EOD
A gcloud command that will SSH via IAP to bastion host.
EOD
}

output "tunnel_command" {
  value       = format("gcloud compute start-iap-tunnel %s %d --local-host-port localhost:%d --project=%s --zone=%s", module.bastion.hostname, var.remote_port, var.local_port, var.project_id, var.zone)
  description = <<-EOD
A gcloud command that create a tunnel between localhost and bastion via IAP;
connections to localhost:PORT will be tunneled to bastion forward-proxy. The value
of PORT will be taken from `local_port` variable, with 8888 as the default.
EOD
}

output "ip_address" {
  value       = module.bastion.ip_address
  description = <<-EOD
The private IP address of the bastion instance.
EOD
}

output "self_link" {
  value       = module.bastion.self_link
  description = <<-EOD
The self-link of the bastion instance.
EOD
}

data "google_compute_instance" "bastion" {
  count     = var.external_ip ? 1 : 0
  self_link = module.bastion.self_link
}

output "public_ip_address" {
  value = try(data.google_compute_instance.bastion[0].network_interface[0].access_config[0].nat_ip, "")
}
