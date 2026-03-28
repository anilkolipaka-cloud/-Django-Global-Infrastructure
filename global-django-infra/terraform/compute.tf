# US Cloud Run Service
resource "google_cloud_run_v2_service" "us_service" {
  name     = "django-app-us"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "us-central1-docker.pkg.dev/${var.project_id}/django-repo/django-app:v1"
      env {
        name  = "PRIMARY_DB_HOST"
        value = google_sql_database_instance.primary.ip_address[0].ip_address
      }
      env {
        name  = "REPLICA_DB_HOST"
        value = google_sql_database_instance.replica.ip_address[0].ip_address
      }
      env {
        name  = "REGION"
        value = "US"
      }
      env {
        name  = "DB_PASSWORD"
        value = "placeholder123" # In prod, use Secret Manager
      }
    }
    vpc_access {
      connector = google_vpc_access_connector.us_connector.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# EU Cloud Run Service
resource "google_cloud_run_v2_service" "eu_service" {
  name     = "django-app-eu"
  location = "europe-west1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "us-central1-docker.pkg.dev/${var.project_id}/django-repo/django-app:v1"
      env {
        name  = "PRIMARY_DB_HOST"
        value = google_sql_database_instance.primary.ip_address[0].ip_address
      }
      env {
        name  = "REPLICA_DB_HOST"
        value = google_sql_database_instance.replica.ip_address[0].ip_address
      }
      env {
        name  = "REGION"
        value = "EU"
      }
      env {
        name  = "DB_PASSWORD"
        value = "placeholder123" # In prod, use Secret Manager
      }
    }
    vpc_access {
      connector = google_vpc_access_connector.eu_connector.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# Network Endpoint Groups (Serverless NEGs) for Load Balancer
resource "google_compute_region_network_endpoint_group" "us_neg" {
  name                  = "us-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_v2_service.us_service.name
  }
}

resource "google_compute_region_network_endpoint_group" "eu_neg" {
  name                  = "eu-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "europe-west1"
  cloud_run {
    service = google_cloud_run_v2_service.eu_service.name
  }
}
