terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Service Account for Grafana
resource "google_service_account" "grafana" {
  account_id   = "grafana-sa"
  display_name = "Grafana Service Account"
}

# Cloud Run service for Grafana
resource "google_cloud_run_v2_service" "grafana" {
  name     = "grafana"
  location = var.region

  template {
    service_account = google_service_account.grafana.email

    containers {
      image = var.grafana_image

      ports {
        container_port = 3000
      }

      env {
        name  = "GF_SECURITY_ADMIN_USER"
        value = var.admin_user
      }

      env {
        name  = "GF_SECURITY_ADMIN_PASSWORD"
        value = var.admin_password
      }

      env {
        name  = "GF_SERVER_ROOT_URL"
        value = var.root_url
      }

      env {
        name  = "GF_INSTALL_PLUGINS"
        value = "grafana-piechart-panel"
      }

      # Prometheus datasource
      env {
        name  = "GF_DATASOURCES_PROMETHEUS_URL"
        value = var.prometheus_url
      }

      # Loki datasource
      env {
        name  = "GF_DATASOURCES_LOKI_URL"
        value = var.loki_url
      }

      # Tempo datasource
      env {
        name  = "GF_DATASOURCES_TEMPO_URL"
        value = var.tempo_url
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
resource "google_cloud_run_service_iam_member" "grafana_public" {
  count    = var.allow_public_access ? 1 : 0
  service  = google_cloud_run_v2_service.grafana.name
  location = google_cloud_run_v2_service.grafana.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# IAM policy for authenticated access
resource "google_cloud_run_service_iam_member" "grafana_authenticated" {
  count    = var.allow_authenticated_access ? 1 : 0
  service  = google_cloud_run_v2_service.grafana.name
  location = google_cloud_run_v2_service.grafana.location
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}

# Cloud Storage bucket for Grafana provisioning
resource "google_storage_bucket" "grafana_provisioning" {
  name          = "${var.project_id}-grafana-provisioning"
  location      = var.region
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true
}

