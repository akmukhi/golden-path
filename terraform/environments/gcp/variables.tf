variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

# Prometheus variables
variable "prometheus_image" {
  description = "Prometheus Docker image"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "prometheus_cpu_limit" {
  description = "CPU limit for Prometheus"
  type        = string
  default     = "2"
}

variable "prometheus_memory_limit" {
  description = "Memory limit for Prometheus"
  type        = string
  default     = "4Gi"
}

variable "prometheus_min_instances" {
  description = "Minimum instances for Prometheus"
  type        = number
  default     = 1
}

variable "prometheus_max_instances" {
  description = "Maximum instances for Prometheus"
  type        = number
  default     = 3
}

# Loki variables
variable "loki_image" {
  description = "Loki Docker image"
  type        = string
  default     = "grafana/loki:latest"
}

variable "loki_cpu_limit" {
  description = "CPU limit for Loki"
  type        = string
  default     = "2"
}

variable "loki_memory_limit" {
  description = "Memory limit for Loki"
  type        = string
  default     = "4Gi"
}

variable "loki_min_instances" {
  description = "Minimum instances for Loki"
  type        = number
  default     = 1
}

variable "loki_max_instances" {
  description = "Maximum instances for Loki"
  type        = number
  default     = 3
}

# Tempo variables
variable "tempo_image" {
  description = "Tempo Docker image"
  type        = string
  default     = "grafana/tempo:latest"
}

variable "tempo_cpu_limit" {
  description = "CPU limit for Tempo"
  type        = string
  default     = "2"
}

variable "tempo_memory_limit" {
  description = "Memory limit for Tempo"
  type        = string
  default     = "4Gi"
}

variable "tempo_min_instances" {
  description = "Minimum instances for Tempo"
  type        = number
  default     = 1
}

variable "tempo_max_instances" {
  description = "Maximum instances for Tempo"
  type        = number
  default     = 3
}

# Grafana variables
variable "grafana_image" {
  description = "Grafana Docker image"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_root_url" {
  description = "Grafana root URL"
  type        = string
  default     = "%(protocol)s://%(domain)s:%(http_port)s/"
}

variable "grafana_cpu_limit" {
  description = "CPU limit for Grafana"
  type        = string
  default     = "1"
}

variable "grafana_memory_limit" {
  description = "Memory limit for Grafana"
  type        = string
  default     = "2Gi"
}

variable "grafana_min_instances" {
  description = "Minimum instances for Grafana"
  type        = number
  default     = 1
}

variable "grafana_max_instances" {
  description = "Maximum instances for Grafana"
  type        = number
  default     = 3
}

# Common variables
variable "retention_days" {
  description = "Data retention in days"
  type        = number
  default     = 30
}

variable "force_destroy" {
  description = "Force destroy storage buckets"
  type        = bool
  default     = false
}

variable "allow_public_access" {
  description = "Allow public access to services"
  type        = bool
  default     = false
}

variable "allow_authenticated_access" {
  description = "Allow authenticated access to services"
  type        = bool
  default     = true
}

