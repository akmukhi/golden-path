variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "grafana_image" {
  description = "Grafana Docker image"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
  sensitive   = false
}

variable "admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "root_url" {
  description = "Grafana root URL"
  type        = string
  default     = "%(protocol)s://%(domain)s:%(http_port)s/"
}

variable "prometheus_url" {
  description = "Prometheus service URL"
  type        = string
}

variable "loki_url" {
  description = "Loki service URL"
  type        = string
}

variable "tempo_url" {
  description = "Tempo service URL"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit for Grafana container"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit for Grafana container"
  type        = string
  default     = "2Gi"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "force_destroy" {
  description = "Force destroy storage bucket"
  type        = bool
  default     = false
}

variable "allow_public_access" {
  description = "Allow public access to Grafana"
  type        = bool
  default     = false
}

variable "allow_authenticated_access" {
  description = "Allow authenticated access to Grafana"
  type        = bool
  default     = true
}

