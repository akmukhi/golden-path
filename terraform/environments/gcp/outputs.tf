output "prometheus_url" {
  description = "Prometheus service URL"
  value       = module.prometheus.prometheus_url
}

output "loki_url" {
  description = "Loki service URL"
  value       = module.loki.loki_url
}

output "tempo_url" {
  description = "Tempo service URL"
  value       = module.tempo.tempo_url
}

output "grafana_url" {
  description = "Grafana service URL"
  value       = module.grafana.grafana_url
}

output "grafana_admin_user" {
  description = "Grafana admin username"
  value       = var.grafana_admin_user
}

