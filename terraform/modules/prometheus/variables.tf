variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "prometheus_image" {
  description = "Prometheus Docker image"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "cpu_limit" {
  description = "CPU limit for Prometheus container"
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Memory limit for Prometheus container"
  type        = string
  default     = "4Gi"
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

variable "retention_days" {
  description = "Data retention in days"
  type        = number
  default     = 30
}

variable "force_destroy" {
  description = "Force destroy storage bucket"
  type        = bool
  default     = false
}

variable "allow_public_access" {
  description = "Allow public access to Prometheus"
  type        = bool
  default     = false
}

variable "allow_authenticated_access" {
  description = "Allow authenticated access to Prometheus"
  type        = bool
  default     = true
}

