provider "google" {
  credentials = file("gcp-3tier-application-06c0eb3106c8.json")
  project = "gcp-3tier-application"      
  region  = "us-central1"          
  zone    = "us-central1-a"
} 


# Disk resource - persistent disk to be used as additional disk for the instances
resource "google_compute_disk" "foobar" {
  name  = "additional-disk"
  image = "debian-cloud/debian-11"  # Debian 11 image to use for the disk
  size  = 10                       # Size of the disk in GB
  type  = "pd-ssd"                  # Persistent SSD disk type
  zone  = "us-central1-a"           # Zone where the disk will be created
}

#Creating snapshot of additional disk
resource "google_compute_snapshot" "foobar_snapshot" {
  name        = "foobar-disk-snapshot-001"
  source_disk = google_compute_disk.foobar.id
  zone        = "us-central1-a"
  description = "Snapshot of the additional disk"
}

# Instance Template creation
resource "google_compute_instance_template" "default" {
  name        = "instance-template"
  description = "This template is used to create VM instances."
  tags        = ["foo", "bar"]

  
  machine_type         = "e2-small"  # Machine type (2 vCPUs, 4 GB RAM)
  can_ip_forward       = true        # Disabling IP forwarding


  # Boot disk configuration (Debian 11 image)
  disk {
    source_image      = "debian-cloud/debian-11"
    auto_delete       = true
    boot              = true
  }

  # Additional disk (existing disk created earlier)
  disk {
    source      = google_compute_disk.foobar.name
    auto_delete = false
    boot        = false
  }

  # Network interface configuration
  network_interface {
    network = "default"  # Attach to the default VPC network
    access_config {     # Create an external IP for the instance
      nat_ip = null      # Optional: set to null if no external IP is required
    }
  }

  # Metadata associated with the instance
  metadata = {
    foo = "bar"
  }
}

# Data source for the Debian 11 image
data "google_compute_image" "my_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

# Single VM instance using the instance template
/*resource "google_compute_instance" "my_instance" {
  name         = "my-instance"
  zone         = "us-central1-a"
  machine_type = "e2-medium"
  instance_template = google_compute_instance_template.default.id
}
*/

# Single VM instance using the instance template
resource "google_compute_instance_from_template" "instancewithtemplate" {
  name = "instancewithtemplates"
  zone = "us-central1-a"

  source_instance_template = google_compute_instance_template.default.id

  // Override fields from instance template
  can_ip_forward = false
  
}
