resource "google_project_service" "project_apis" {
  for_each = toset(distinct(concat(var.default_apis_to_enable, var.additional_apis_to_enable)))
  project  = var.project_id
  service  = each.value

  disable_on_destroy         = false // Important: Keep false if other resources depend on these APIs
  disable_dependent_services = false
}

resource "google_service_account" "terraform_sa" {
  project      = var.project_id
  account_id   = var.terraform_service_account_id
  display_name = "Terraform Server Service Account"
  description  = "Service account for the Terraform server VM to manage GCP resources in project ${var.project_id}."
  depends_on   = [google_project_service.project_apis] // Ensure IAM API is enabled
}

resource "google_project_iam_member" "sa_project_roles" {
  for_each = toset(var.project_iam_roles_for_sa)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform_sa.email}"
  depends_on = [google_service_account.terraform_sa]
}

resource "google_storage_bucket" "tfstate_bucket" {
  project                     = var.project_id
  name                        = "${var.project_id}${var.tf_state_bucket_name_suffix}" # Must be globally unique
  location                    = var.gcp_region
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 10 // Keep last 10 versions of state files
    }
  }
  depends_on = [google_project_service.project_apis] // Ensure Storage API is enabled
}

resource "google_storage_bucket_iam_member" "tfstate_bucket_sa_admin" {
  bucket = google_storage_bucket.tfstate_bucket.name
  role   = "roles/storage.objectAdmin" // Allows SA to read/write state files
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
  depends_on = [google_storage_bucket.tfstate_bucket, google_service_account.terraform_sa]
}
