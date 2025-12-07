output "tempo_url" {
  description = "Tempo service URL"
  value       = google_cloud_run_v2_service.tempo.uri
}

output "tempo_service_name" {
  description = "Tempo Cloud Run service name"
  value       = google_cloud_run_v2_service.tempo.name
}

output "storage_bucket_name" {
  description = "Tempo data storage bucket name"
  value       = google_storage_bucket.tempo_data.name
}

output "service_account_email" {
  description = "Tempo service account email"
  value       = google_service_account.tempo.email
}

