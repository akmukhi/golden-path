output "prometheus_url" {
  description = "Prometheus service URL"
  value       = google_cloud_run_v2_service.prometheus.uri
}

output "prometheus_service_name" {
  description = "Prometheus Cloud Run service name"
  value       = google_cloud_run_v2_service.prometheus.name
}

output "storage_bucket_name" {
  description = "Prometheus data storage bucket name"
  value       = google_storage_bucket.prometheus_data.name
}

output "service_account_email" {
  description = "Prometheus service account email"
  value       = google_service_account.prometheus.email
}

