output "ssh_command" {
  value       = format("gcloud compute ssh %s --tunnel-through-iap --strict-host-key-checking=no --ssh-flag=-oUserKnownHostsFile=/dev/null --ssh-flag=-A --project=%s --zone=%s", module.bastion.hostname, var.project_id, var.zone)
  description = <<-EOD
A gcloud command that will SSH via IAP to bastion host.
EOD
}

output "tunnel_command" {
  value       = format("gcloud compute start-iap-tunnel %s 8888 --local-host-port localhost:8888 --project=%s --zone=%s", module.bastion.hostname, var.project_id, var.zone)
  description = <<-EOD
A gcloud command that create a tunnel between localhost:8888 via IAP to bastion
host; connections to localhost:8888 will be tunneled to bastion forward-proxy.
EOD
}

output "ip_address" {
  value       = module.bastion.ip_address
  description = <<-EOD
The private IP address of the bastion instance.
EOD
}
