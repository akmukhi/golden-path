output "grafana_url" {
  description = "Grafana service URL"
  value       = google_cloud_run_v2_service.grafana.uri
}

output "grafana_service_name" {
  description = "Grafana Cloud Run service name"
  value       = google_cloud_run_v2_service.grafana.name
}

output "service_account_email" {
  description = "Grafana service account email"
  value       = google_service_account.grafana.email
}

