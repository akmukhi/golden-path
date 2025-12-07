# Setup Guide

This guide provides detailed instructions for setting up the Golden Path observability stack.

## Prerequisites

### For Local Development
- Docker and Docker Compose
- Python 3.8+ (for using the Python library)

### For GCP Deployment
- Google Cloud Platform account
- Terraform >= 1.0
- gcloud CLI configured with appropriate permissions
- GCP project with billing enabled

## Local Development Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/golden-path.git
cd golden-path
```

### Step 2: Start Services

Start all observability services:

```bash
docker-compose up -d
```

This will start:
- Prometheus on port 9090
- Loki on port 3100
- Tempo on port 3200
- Grafana on port 3000

### Step 3: Verify Services

Check that all services are running:

```bash
docker-compose ps
```

All services should show as "Up" and healthy.

### Step 4: Access Grafana

1. Open http://localhost:3000 in your browser
2. Login with:
   - Username: `admin`
   - Password: `admin`
3. Change the password when prompted (optional for local dev)

### Step 5: Import Dashboard

1. In Grafana, go to Dashboards → Import
2. Click "Upload JSON file"
3. Select `dashboards/unified-dashboard.json`
4. Click "Import"

The unified dashboard should now be available with pre-configured panels for metrics, logs, and traces.

### Step 6: Configure Application Scraping

Edit `prometheus/prometheus.yml` to add your application endpoints:

```yaml
scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['host.docker.internal:8000']
    metrics_path: '/metrics'
```

Restart Prometheus:

```bash
docker-compose restart prometheus
```

## GCP Deployment Setup

### Step 1: Configure GCP Project

1. Create a new GCP project or use an existing one
2. Enable required APIs:
   ```bash
   gcloud services enable run.googleapis.com
   gcloud services enable storage-component.googleapis.com
   gcloud services enable iam.googleapis.com
   ```

### Step 2: Set Up Terraform Variables

1. Navigate to the GCP environment:
   ```bash
   cd terraform/environments/gcp
   ```

2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars`:
   ```hcl
   project_id = "your-gcp-project-id"
   region     = "us-central1"
   
   grafana_admin_password = "your-secure-password"
   ```

### Step 3: Initialize Terraform

```bash
terraform init
```

This will download the required Terraform providers.

### Step 4: Plan Deployment

Review the deployment plan:

```bash
terraform plan
```

This will show what resources will be created.

### Step 5: Apply Configuration

Deploy the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted. This will create:
- Cloud Run services for each component
- Cloud Storage buckets for data persistence
- Service accounts with appropriate permissions
- IAM bindings

### Step 6: Get Service URLs

After deployment, get the service URLs:

```bash
terraform output
```

You'll see output like:
```
grafana_url = "https://grafana-xxxxx.run.app"
prometheus_url = "https://prometheus-xxxxx.run.app"
loki_url = "https://loki-xxxxx.run.app"
tempo_url = "https://tempo-xxxxx.run.app"
```

### Step 7: Configure Grafana Data Sources

The Terraform modules automatically configure Grafana data sources, but you can verify:

1. Open the Grafana URL from the output
2. Go to Configuration → Data Sources
3. Verify Prometheus, Loki, and Tempo are configured

### Step 8: Import Dashboard

1. In Grafana, go to Dashboards → Import
2. Upload `dashboards/unified-dashboard.json`
3. The dashboard should work with the GCP-deployed services

## Python Library Setup

### Installation

1. Navigate to the library directory:
   ```bash
   cd library/python
   ```

2. Install in development mode:
   ```bash
   pip install -e .
   ```

   Or install from requirements:
   ```bash
   pip install -r requirements.txt
   ```

### Configuration

When using the library, configure the observability endpoints:

```python
from golden_path import ObservabilityMiddleware

observability = ObservabilityMiddleware(
    service_name="my-service",
    environment="production",
    version="1.0.0",
    # Optional: Override defaults
    # tempo_endpoint="https://tempo.example.com:4317"
)
```

### Running Examples

1. Flask example:
   ```bash
   cd library/python/examples
   python flask_example.py
   ```

2. FastAPI example:
   ```bash
   python fastapi_example.py
   ```

3. Basic example:
   ```bash
   python basic_example.py
   ```

## Troubleshooting

### Services Not Starting

If services fail to start:

1. Check logs:
   ```bash
   docker-compose logs
   ```

2. Verify ports are not in use:
   ```bash
   lsof -i :3000 -i :9090 -i :3100 -i :3200
   ```

3. Check Docker resources:
   ```bash
   docker system df
   ```

### Terraform Errors

Common issues:

1. **Authentication errors**: Run `gcloud auth application-default login`
2. **Permission errors**: Ensure your GCP account has necessary permissions
3. **API not enabled**: Enable required APIs (see Step 1 of GCP setup)

### Metrics Not Appearing

1. Verify Prometheus is scraping your application:
   - Check http://localhost:9090/targets
   - Ensure your app exposes `/metrics` endpoint

2. Check service labels match dashboard variables:
   - Dashboard uses `service` and `environment` labels
   - Ensure your metrics include these labels

### Traces Not Appearing

1. Verify Tempo is receiving traces:
   - Check Tempo logs: `docker-compose logs tempo`

2. Ensure OpenTelemetry is configured correctly:
   - Check `tempo_endpoint` in your application
   - Verify OTLP exporter is working

## Next Steps

- Read the [Usage Guide](USAGE.md) for detailed library usage
- Review the [Architecture](ARCHITECTURE.md) documentation
- Customize dashboards and alerts for your needs

