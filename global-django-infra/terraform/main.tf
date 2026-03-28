terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# 1. VPC Network
resource "google_compute_network" "main" {
  name                    = "global-django-vpc"
  auto_create_subnetworks = false
}

# 2. Subnets (US and EU)
resource "google_compute_subnetwork" "us" {
  name          = "django-subnet-us"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
}

resource "google_compute_subnetwork" "eu" {
  name          = "django-subnet-eu"
  ip_cidr_range = "10.0.2.0/24"
  region        = "europe-west1"
  network       = google_compute_network.main.id
}

# 3. Private Service Access for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# 4. Serverless VPC Connectors
resource "google_vpc_access_connector" "us_connector" {
  name          = "us-conn"
  region        = "us-central1"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.main.name
  depends_on    = [google_service_networking_connection.private_vpc_connection]
}

resource "google_vpc_access_connector" "eu_connector" {
  name          = "eu-conn"
  region        = "europe-west1"
  ip_cidr_range = "10.9.0.0/28"
  network       = google_compute_network.main.name
  depends_on    = [google_service_networking_connection.private_vpc_connection]
}
