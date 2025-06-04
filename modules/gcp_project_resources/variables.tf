variable "project_id" {
  type        = string
  description = "The ID of the existing GCP project where resources will be managed."
}

variable "gcp_region" {
  type        = string
  description = "GCP region for the GCS state bucket."
}

variable "tf_state_bucket_name_suffix" {
  type        = string
  description = "Suffix for the Terraform state GCS bucket name."
}

variable "terraform_service_account_id" {
  type        = string
  description = "ID for the Terraform service account (e.g., 'tf-server-sa')."
}

variable "project_iam_roles_for_sa" {
  type        = list(string)
  description = "List of IAM roles to grant the service account on the project."
}

variable "default_apis_to_enable" {
  type        = list(string)
  description = "Default APIs to enable on the project."
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "storage-api.googleapis.com", // Alias for storage.googleapis.com
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com", // Needed for project-level IAM
    "iamcredentials.googleapis.com",       // Often needed by tools using SA credentials
  ]
}

variable "additional_apis_to_enable" {
  type        = list(string)
  description = "Additional APIs to enable on the project."
  default     = []
}
