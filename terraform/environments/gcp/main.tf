terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Deploy Prometheus
module "prometheus" {
  source = "../../modules/prometheus"

  project_id              = var.project_id
  region                  = var.region
  prometheus_image        = var.prometheus_image
  cpu_limit               = var.prometheus_cpu_limit
  memory_limit            = var.prometheus_memory_limit
  min_instances           = var.prometheus_min_instances
  max_instances           = var.prometheus_max_instances
  retention_days          = var.retention_days
  force_destroy           = var.force_destroy
  allow_public_access     = var.allow_public_access
  allow_authenticated_access = var.allow_authenticated_access
}

# Deploy Loki
module "loki" {
  source = "../../modules/loki"

  project_id              = var.project_id
  region                  = var.region
  loki_image              = var.loki_image
  cpu_limit               = var.loki_cpu_limit
  memory_limit            = var.loki_memory_limit
  min_instances           = var.loki_min_instances
  max_instances           = var.loki_max_instances
  retention_days          = var.retention_days
  force_destroy           = var.force_destroy
  allow_public_access     = var.allow_public_access
  allow_authenticated_access = var.allow_authenticated_access
}

# Deploy Tempo
module "tempo" {
  source = "../../modules/tempo"

  project_id              = var.project_id
  region                  = var.region
  tempo_image             = var.tempo_image
  cpu_limit               = var.tempo_cpu_limit
  memory_limit            = var.tempo_memory_limit
  min_instances           = var.tempo_min_instances
  max_instances           = var.tempo_max_instances
  retention_days          = var.retention_days
  force_destroy           = var.force_destroy
  allow_public_access     = var.allow_public_access
  allow_authenticated_access = var.allow_authenticated_access
}

# Deploy Grafana
module "grafana" {
  source = "../../modules/grafana"

  project_id              = var.project_id
  region                  = var.region
  grafana_image           = var.grafana_image
  admin_user              = var.grafana_admin_user
  admin_password          = var.grafana_admin_password
  root_url                = var.grafana_root_url
  prometheus_url          = module.prometheus.prometheus_url
  loki_url                = module.loki.loki_url
  tempo_url               = module.tempo.tempo_url
  cpu_limit               = var.grafana_cpu_limit
  memory_limit            = var.grafana_memory_limit
  min_instances           = var.grafana_min_instances
  max_instances           = var.grafana_max_instances
  force_destroy           = var.force_destroy
  allow_public_access     = var.allow_public_access
  allow_authenticated_access = var.allow_authenticated_access
}

