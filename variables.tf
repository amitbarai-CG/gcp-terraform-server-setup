variable "existing_project_id" {
  type        = string
  description = "The Project ID of your existing GCP project (e.g., 'my-first-project-12345')."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region for deploying resources like the GCS bucket."
  default     = "us-central1"
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone for deploying the VM."
  default     = "us-central1-a"
}

variable "vm_machine_type" {
  type        = string
  description = "The machine type for the Terraform server VM."
  default     = "e2-micro" // Free tier eligible in some regions
}

variable "vm_image" {
  type        = string
  description = "The image for the Terraform server VM."
  default     = "debian-cloud/debian-11"
}

variable "terraform_server_vm_name" {
  type        = string
  description = "Name for the Terraform server VM."
  default     = "terraform-server"
}

variable "tf_state_bucket_name_suffix" {
  type        = string
  description = "Suffix for the Terraform state GCS bucket name. Bucket name will be <existing_project_id><suffix>."
  default     = "-tfstate"
}

variable "terraform_service_account_id" {
  type        = string
  description = "The ID for the Terraform service account (e.g., 'tf-server-sa')."
  default     = "tf-server-sa"
}

variable "project_iam_roles_for_sa" {
  type        = list(string)
  description = "List of IAM roles to grant to the Terraform service account on the existing project."
  default     = ["roles/editor"] // Provides broad access within the project
}

variable "additional_apis_to_enable" {
  type        = list(string)
  description = "Additional APIs to enable on the existing project, beyond the defaults."
  default     = [] // e.g., ["sqladmin.googleapis.com"] if you plan to manage Cloud SQL
}

variable "allow_ssh_cidr_ranges" {
  type        = list(string)
  description = "List of CIDR ranges to allow SSH access to the VM. For unrestricted access (not recommended for production), use [\"0.0.0.0/0\"]."
  default     = ["0.0.0.0/0"] // WARNING: Allows SSH from anywhere. Restrict this in production.
}

variable "startup_script" {
  type        = string
  description = "Startup script to run on the VM instance for installing software. If not provided, the module's default script will be used."
  default     = null // Setting to null means if not explicitly set in root, module's default is used.
                     // Alternatively, you could copy the module's default here.
}
