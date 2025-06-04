
# GCP Terraform Server Setup in Existing Project

This Terraform configuration automates the setup of a dedicated Terraform server environment within your **existing** GCP project. It creates:

1.  A **GCS bucket** within your existing project for storing Terraform state files.
2.  A **Service Account** within your existing project. This Service Account will be granted:
    *   `Editor` role on the project (allowing it to manage most resources).
    *   `Storage Object Admin` role on the state bucket (allowing it to read/write state files).
3.  A **Compute Engine VM instance** (using an Ubuntu image with a 10GB boot disk by default) in your existing project. This VM will:
    *   Be configured to use the created Service Account for authentication.
    *   Have Terraform and the Google Cloud CLI installed via a startup script.
    *   Serve as your primary machine for running Terraform commands to manage resources within this project.

## Prerequisites

1.  **Terraform Installed:**
    *   **If using GCP Cloud Shell:** Terraform is typically pre-installed. You can verify by opening Cloud Shell and typing `terraform version`.
    *   **If using a local machine:** Ensure Terraform CLI is installed.
2.  **GCP Account & Existing Project:**
    *   You need a GCP account with billing enabled.
    *   You must have an existing GCP Project (e.g., "My First Project"). Note its **Project ID**.
    *   **If using GCP Cloud Shell:** Ensure your Cloud Shell session is configured for the project where you have the necessary permissions, or the project you intend to use as `existing_project_id`. You can set the project for Cloud Shell using `gcloud config set project YOUR_PROJECT_ID`.
3.  **Permissions:**
    *   The GCP user account you are logged in with (either in Cloud Shell or on your local machine via `gcloud auth application-default login`) must have the following permissions **on your existing project** (the one specified in `existing_project_id`):
        *   `roles/serviceusage.serviceUsageAdmin` (to enable necessary APIs).
        *   `roles/storage.admin` (to create GCS buckets and set IAM policies).
        *   `roles/iam.serviceAccountAdmin` (to create Service Accounts).
        *   `roles/resourcemanager.projectIamAdmin` (to grant roles to the Service Account on the project).
        *   `roles/compute.admin` (to create VM instances and firewall rules).
        *   (Alternatively, `roles/owner` or `roles/editor` on the project usually covers these).

## Setup Instructions

### Step 1: Get the Code and Configure Variables

1.  **Get the Terraform files into your environment:**
    *   **If using GCP Cloud Shell:** You can clone your Git repository containing these files into Cloud Shell, or use the Cloud Shell Editor to create/upload the files.
    *   **If using a local machine:** Ensure you have the files locally.
2.  Navigate to the root directory of this configuration (where `main.tf` is located).
3.  Create a file named `terraform.tfvars` in the root directory (if it doesn't exist).
4.  Update `terraform.tfvars` with your specific values:
    *   `existing_project_id`: **Crucial!** The Project ID of your existing GCP project (e.g., "my-first-project-12345").
    *   `gcp_region`: The GCP region for resources (default: "us-central1").
    *   `gcp_zone`: The GCP zone for the VM (default: "us-central1-a").
    *   `vm_machine_type`: Machine type for the Terraform server VM (default: "e2-micro").
    *   `allow_ssh_cidr_ranges`: **Strongly Recommended:** Change the default `["0.0.0.0/0"]` to a more restrictive range like `["YOUR_HOME_IP_ADDRESS/32"]` for security.

    Example `terraform.tfvars`:
    ```terraform
    existing_project_id = "my-first-project-12345" # REQUIRED: Replace with the Project ID of "My First Project"

    // Optional overrides
    // gcp_region         = "us-central1"
    // gcp_zone           = "us-central1-a"
    // vm_machine_type    = "e2-micro"
    // terraform_server_vm_name = "my-tf-vm"
    // allow_ssh_cidr_ranges = ["YOUR_HOME_IP_ADDRESS/32"] # Recommended for better security
    ```

### Step 2: Initial Terraform Apply (Local Machine or Cloud Shell)

This step creates the GCS bucket for state, the Service Account, and the VM within your existing project. The Terraform state will be stored locally for this initial apply.

1.  Initialize Terraform:
    ```bash
    terraform init
    ```
2.  Review the plan:
    ```bash
    terraform plan
    ```
3.  Apply the configuration:
    ```bash
    terraform apply
    ```
    Confirm with `yes` when prompted. Note the output `tf_state_gcs_bucket_name`.

### Step 3: Configure GCS Backend and Migrate State

Now that the GCS bucket for Terraform state is created (its name will be an output from the previous step), you'll configure Terraform to use it.

1.  Open `main.tf` in the root directory.
2.  Uncomment the `terraform backend "gcs"` block.
3.  Replace `YOUR_TF_STATE_BUCKET_NAME_HERE` with the actual bucket name you noted from the `terraform apply` output (it will be in the format `<EXISTING_PROJECT_ID>-tfstate`).

    ```terraform
    terraform {
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = "~> 5.0"
        }
      }
      # STEP 3: Uncomment and update this block after initial apply
      backend "gcs" {
        bucket = "YOUR_TF_STATE_BUCKET_NAME_HERE" # <-- UPDATE THIS (e.g., "my-first-project-12345-tfstate")
        prefix = "terraform/state/project-server"
      }
    }
    ```
    After uncommenting and updating, it should look like (example):
    ```terraform
    terraform {
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = "~> 5.0"
        }
      }
      backend "gcs" {
        bucket = "my-first-project-12345-tfstate" # Replace with your actual bucket name
        prefix = "terraform/state/project-server"
      }
    }
    ```

4.  Re-initialize Terraform. This time, it will prompt you to migrate your local state to the GCS backend:
    ```bash
    terraform init -migrate-state
    ```
    Confirm with `yes`.

Your Terraform state is now securely stored in the GCS bucket within "My First Project".

### Step 4: Using the Terraform Server VM

1.  **SSH into the VM:**
    You can find the VM's external IP address from the `terraform_server_vm_external_ip` output or via the GCP Console.
    ```bash
    gcloud compute ssh --project <YOUR_EXISTING_PROJECT_ID> --zone <YOUR_GCP_ZONE> <TERRAFORM_SERVER_VM_NAME>
    ```
    (Replace placeholders with actual values from your `terraform.tfvars` and outputs).

2.  **Verify Setup:**
    Terraform and gcloud CLI should be installed on the VM via the startup script. The VM is authenticated using the attached service account.
    ```bash
    terraform version
    gcloud auth list
    ```
    You should see the service account (e.g., `tf-server-sa@<YOUR_EXISTING_PROJECT_ID>.iam.gserviceaccount.com`) as active.

3.  **Run Terraform Commands:**
    You can now clone your Terraform configurations onto this VM and run `terraform init`, `terraform plan`, and `terraform apply` to manage resources within "My First Project". The state will be automatically managed in the GCS bucket.

## Outputs

After `terraform apply`, you will get these outputs:
*   `existing_project_id_used`: The ID of the existing GCP project where resources were deployed.
*   `terraform_service_account_email`: The email of the service account created for the Terraform VM.
*   `tf_state_gcs_bucket_name`: The name of the GCS bucket created for Terraform state.
*   `terraform_server_vm_name`: The name of the Terraform server VM.
*   `terraform_server_vm_external_ip`: The external IP address of the Terraform server VM.

## Security Considerations

*   The default `allow_ssh_cidr_ranges = ["0.0.0.0/0"]` in `variables.tf` creates a firewall rule allowing SSH access from *anywhere* on the internet. **This is highly insecure for production environments.** It is strongly recommended to change this to a specific IP range (e.g., your home or office IP address with a `/32` suffix).
*   The Service Account is granted the `roles/editor` role by default. This provides broad permissions within the project. For production, consider using more granular, least-privilege roles specific to the resources you plan to manage with Terraform from this VM.