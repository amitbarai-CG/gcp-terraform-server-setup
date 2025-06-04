data "google_compute_image" "vm_os_image" {
  # If var.vm_image is "debian-cloud/debian-11", family is "debian-11", project is "debian-cloud"
  # If var.vm_image is "projects/PROJECT_ID/global/images/FAMILY" or "projects/PROJECT_ID/global/images/NAME"
  # this logic might need adjustment or a more robust parsing method.
  # For common public images like "debian-cloud/debian-11", this split works.
  family  = split("/", var.vm_image)[1] # Assumes format like "project/family" e.g. "debian-cloud/debian-11"
  project = split("/", var.vm_image)[0]
}

resource "google_compute_instance" "terraform_server" {
  project      = var.project_id
  zone         = var.zone
  name         = var.vm_name
  machine_type = var.machine_type

  tags = ["terraform-server", "allow-ssh"] // Tag for firewall rule

  boot_disk {
    initialize_params {
      image = data.google_compute_image.vm_os_image.self_link
      size  = var.boot_disk_size_gb
    }
  }

  network_interface {
    network = var.network_name // "default" or a custom network
    access_config {
      // Empty access_config block requests an ephemeral external IP.
      // Omit this block entirely for an internal-IP-only VM.
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"] // Full access based on SA's IAM roles on the project
  }

  metadata = {
    "startup-script" = var.startup_script
  }

  allow_stopping_for_update = true
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  count   = length(var.allow_ssh_cidr_ranges) > 0 ? 1 : 0
  project = var.project_id
  name    = "${var.vm_name}-allow-ssh"
  network = "global/networks/${var.network_name}" // Assumes network is in the same project

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allow_ssh_cidr_ranges
  target_tags   = ["allow-ssh"] // Matches tag on the VM instance
}
