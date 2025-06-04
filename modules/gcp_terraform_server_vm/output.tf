output "vm_instance_name_output" {
  description = "The name of the created VM instance."
  value       = google_compute_instance.terraform_server.name
}

output "vm_instance_external_ip_output" {
  description = "The external IP address of the VM instance."
  value       = google_compute_instance.terraform_server.network_interface[0].access_config[0].nat_ip
  sensitive   = true
}

output "vm_instance_self_link_output" {
  description = "The self_link of the VM instance."
  value       = google_compute_instance.terraform_server.self_link
}
