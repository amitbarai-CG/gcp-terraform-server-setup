output "existing_project_id_used" {
  description = "The ID of the existing GCP project where resources were deployed."
  value       = var.existing_project_id
}

output "terraform_service_account_email" {
  description = "The email of the service account created for the Terraform VM."
  value       = module.project_resources.terraform_service_account_email_output
}

output "tf_state_gcs_bucket_name" {
  description = "The name of the GCS bucket created for Terraform state."
  value       = module.project_resources.tf_state_gcs_bucket_name_output
}

output "terraform_server_vm_name" {
  description = "The name of the Terraform server VM."
  value       = module.terraform_server_vm.vm_instance_name_output
}

output "terraform_server_vm_external_ip" {
  description = "The external IP address of the Terraform server VM."
  value       = module.terraform_server_vm.vm_instance_external_ip_output
  sensitive   = true
}
