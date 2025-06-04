variable "project_id" {
  type        = string
  description = "The ID of the GCP project where the VM will be created."
}

variable "zone" {
  type        = string
  description = "The GCP zone for the VM."
}

variable "vm_name" {
  type        = string
  description = "Name for the VM instance."
}

variable "machine_type" {
  type        = string
  description = "Machine type for the VM."
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to attach to the VM."
}

variable "vm_image" {
  type        = string
  description = "The image for the VM (e.g., 'debian-cloud/debian-11')."
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size_gb" {
  type        = number
  description = "The size of the boot disk in GB."
  default     = 20
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network to attach the VM to."
  default     = "default"
}

variable "startup_script" {
  type        = string
  description = "Startup script to run on the VM instance for installing software."
  default = <<EOT
#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Update package list and install dependencies
sudo apt-get update -y
sudo apt-get install -y wget gnupg software-properties-common curl apt-transport-https ca-certificates lsb-release unzip

# Install Terraform
echo "Installing Terraform..."
TERRAFORM_VERSION="1.6.5" # Specify desired Terraform version
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo mv terraform /usr/local/bin/
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
terraform --version

# Install Google Cloud CLI (if not already present, though most GCP images have it)
if ! command -v gcloud &> /dev/null
then
    echo "Installing Google Cloud CLI..."
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh --quiet --usage-reporting false --path-update true
    # Source the path for the current script session if needed, though reboot or new login usually handles this
    # export PATH=$PATH:/root/google-cloud-sdk/bin # Path might vary based on user
    rm google-cloud-cli-linux-x86_64.tar.gz
fi
gcloud --version

echo "Terraform and gcloud CLI setup complete."
EOT
}

variable "allow_ssh_cidr_ranges" {
  type        = list(string)
  description = "List of CIDR ranges to allow SSH access. Empty list means no firewall rule created by this module."
  default     = ["0.0.0.0/0"] // Be cautious with this default
}
