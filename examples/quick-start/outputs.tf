output "ssh_command" {
  value       = module.bastion.ssh_command
  description = <<-EOD
A gcloud command that will SSH via IAP to bastion host.
EOD
}

output "tunnel_command" {
  value       = module.bastion.tunnel_command
  description = <<-EOD
A gcloud command that create a tunnel between localhost and bastion via IAP;
connections to localhost:PORT will be tunneled to bastion forward-proxy. The value
of PORT will be taken from `local_port` input variable, with 8888 as the default.
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
