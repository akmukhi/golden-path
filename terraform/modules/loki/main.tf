terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Cloud Storage bucket for Loki data
resource "google_storage_bucket" "loki_data" {
  name          = "${var.project_id}-loki-data"
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

# Service Account for Loki
resource "google_service_account" "loki" {
  account_id   = "loki-sa"
  display_name = "Loki Service Account"
}

# IAM binding for Loki to access storage
resource "google_storage_bucket_iam_member" "loki_storage" {
  bucket = google_storage_bucket.loki_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.loki.email}"
}

# Cloud Run service for Loki
resource "google_cloud_run_v2_service" "loki" {
  name     = "loki"
  location = var.region

  template {
    service_account = google_service_account.loki.email

    containers {
      image = var.loki_image

      ports {
        container_port = 3100
      }

      env {
        name  = "LOKI_STORAGE_BACKEND"
        value = "gcs"
      }

      env {
        name  = "LOKI_STORAGE_BUCKET"
        value = google_storage_bucket.loki_data.name
      }

      env {
        name  = "LOKI_STORAGE_PREFIX"
        value = "loki"
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
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
resource "google_cloud_run_service_iam_member" "loki_public" {
  count    = var.allow_public_access ? 1 : 0
  service  = google_cloud_run_v2_service.loki.name
  location = google_cloud_run_v2_service.loki.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# IAM policy for authenticated access
resource "google_cloud_run_service_iam_member" "loki_authenticated" {
  count    = var.allow_authenticated_access ? 1 : 0
  service  = google_cloud_run_v2_service.loki.name
  location = google_cloud_run_v2_service.loki.location
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}

