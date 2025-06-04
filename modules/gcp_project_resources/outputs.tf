output "terraform_service_account_email_output" {
  description = "Email of the created Terraform service account."
  value       = google_service_account.terraform_sa.email
}

output "tf_state_gcs_bucket_name_output" {
  description = "Name of the GCS bucket for Terraform state."
  value       = google_storage_bucket.tfstate_bucket.name
}
