terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Cloud Storage bucket for Tempo data
resource "google_storage_bucket" "tempo_data" {
  name          = "${var.project_id}-tempo-data"
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

# Service Account for Tempo
resource "google_service_account" "tempo" {
  account_id   = "tempo-sa"
  display_name = "Tempo Service Account"
}

# IAM binding for Tempo to access storage
resource "google_storage_bucket_iam_member" "tempo_storage" {
  bucket = google_storage_bucket.tempo_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.tempo.email}"
}

# Cloud Run service for Tempo
resource "google_cloud_run_v2_service" "tempo" {
  name     = "tempo"
  location = var.region

  template {
    service_account = google_service_account.tempo.email

    containers {
      image = var.tempo_image

      ports {
        container_port = 3200
      }

      env {
        name  = "TEMPO_STORAGE_BACKEND"
        value = "gcs"
      }

      env {
        name  = "TEMPO_STORAGE_BUCKET"
        value = google_storage_bucket.tempo_data.name
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
resource "google_cloud_run_service_iam_member" "tempo_public" {
  count    = var.allow_public_access ? 1 : 0
  service  = google_cloud_run_v2_service.tempo.name
  location = google_cloud_run_v2_service.tempo.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# IAM policy for authenticated access
resource "google_cloud_run_service_iam_member" "tempo_authenticated" {
  count    = var.allow_authenticated_access ? 1 : 0
  service  = google_cloud_run_v2_service.tempo.name
  location = google_cloud_run_v2_service.tempo.location
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}

