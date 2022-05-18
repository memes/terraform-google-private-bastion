output "ssh_command" {
  value       = module.bastion.ssh_command
  description = <<-EOD
A gcloud command that will SSH via IAP to bastion host.
EOD
}

output "tunnel_command" {
  value       = module.bastion.tunnel_command
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
