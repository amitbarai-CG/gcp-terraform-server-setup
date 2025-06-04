terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  // STEP 3: Uncomment and update this block after initial apply
  // backend "gcs" {
  //   bucket = "YOUR_TF_STATE_BUCKET_NAME_HERE" // Will be outputted by project_resources module
  //   prefix = "terraform/state/project-server"
  // }
}

provider "google" {
  project = var.existing_project_id
  region  = var.gcp_region
  // Credentials will be sourced from the environment (e.g., gcloud auth application-default login)
}

module "project_resources" {
  source                          = "./modules/gcp_project_resources"
  project_id                      = var.existing_project_id
  gcp_region                      = var.gcp_region
  tf_state_bucket_name_suffix     = var.tf_state_bucket_name_suffix
  terraform_service_account_id    = var.terraform_service_account_id
  project_iam_roles_for_sa        = var.project_iam_roles_for_sa
  additional_apis_to_enable       = var.additional_apis_to_enable
}

module "terraform_server_vm" {
  source                  = "./modules/gcp_terraform_server_vm"
  project_id              = var.existing_project_id
  zone                    = var.gcp_zone
  vm_name                 = var.terraform_server_vm_name
  machine_type            = var.vm_machine_type
  service_account_email   = module.project_resources.terraform_service_account_email_output
  vm_image                = var.vm_image
  allow_ssh_cidr_ranges   = var.allow_ssh_cidr_ranges
  startup_script          = var.startup_script

  depends_on = [module.project_resources] // Ensures SA and APIs are ready
}
