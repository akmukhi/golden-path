terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Cloud Storage bucket for Prometheus data
resource "google_storage_bucket" "prometheus_data" {
  name          = "${var.project_id}-prometheus-data"
  location      = var.region
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.retention_days
    }
    action {
      type = "Delete"
    }
  }
}

# Service Account for Prometheus
resource "google_service_account" "prometheus" {
  account_id   = "prometheus-sa"
  display_name = "Prometheus Service Account"
}

# IAM binding for Prometheus to access storage
resource "google_storage_bucket_iam_member" "prometheus_storage" {
  bucket = google_storage_bucket.prometheus_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.prometheus.email}"
}

# Cloud Run service for Prometheus
resource "google_cloud_run_v2_service" "prometheus" {
  name     = "prometheus"
  location = var.region

  template {
    service_account = google_service_account.prometheus.email

    containers {
      image = var.prometheus_image

      ports {
        container_port = 9090
      }

      env {
        name  = "PROMETHEUS_STORAGE_PATH"
        value = "/prometheus"
      }

      volume_mounts {
        name       = "prometheus-data"
        mount_path = "/prometheus"
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
    }

    volumes {
      name = "prometheus-data"
      gcs {
        bucket    = google_storage_bucket.prometheus_data.name
        read_only = false
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
  }

  traffic {
    percent = 100
    latest_revision = true
  }
}

# IAM policy to allow public access (or restrict as needed)
resource "google_cloud_run_service_iam_member" "prometheus_public" {
  count    = var.allow_public_access ? 1 : 0
  service  = google_cloud_run_v2_service.prometheus.name
  location = google_cloud_run_v2_service.prometheus.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# IAM policy for authenticated access
resource "google_cloud_run_service_iam_member" "prometheus_authenticated" {
  count    = var.allow_authenticated_access ? 1 : 0
  service  = google_cloud_run_v2_service.prometheus.name
  location = google_cloud_run_v2_service.prometheus.location
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}

