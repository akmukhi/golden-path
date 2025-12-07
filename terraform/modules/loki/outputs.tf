output "loki_url" {
  description = "Loki service URL"
  value       = google_cloud_run_v2_service.loki.uri
}

output "loki_service_name" {
  description = "Loki Cloud Run service name"
  value       = google_cloud_run_v2_service.loki.name
}

output "storage_bucket_name" {
  description = "Loki data storage bucket name"
  value       = google_storage_bucket.loki_data.name
}

output "service_account_email" {
  description = "Loki service account email"
  value       = google_service_account.loki.email
}

