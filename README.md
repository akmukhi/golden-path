# Golden Path - Unified Observability Stack

A production-ready unified observability stack with infrastructure-as-code, application instrumentation, and pre-configured dashboards and alerts.

## Overview

Golden Path provides a complete observability solution combining:
- **Prometheus** for metrics collection
- **Loki** for log aggregation
- **Tempo** for distributed tracing
- **Grafana** for visualization and dashboards

All components are pre-configured to work together seamlessly, with automatic correlation between metrics, logs, and traces.

## Features

- 🏗️ **Infrastructure as Code**: Terraform modules for GCP deployment
- 🐳 **Local Development**: Docker Compose setup for quick local testing
- 📊 **Unified Dashboard**: Pre-configured Grafana dashboard with metrics, logs, and traces
- 🔔 **Smart Alerting**: Default alert rules for common issues
- 🐍 **Python Library**: Easy-to-use middleware for Flask, FastAPI, and other frameworks
- 🔗 **Trace Correlation**: Automatic correlation of traces across metrics, logs, and traces

## Quick Start

### Local Development with Docker Compose

1. Clone the repository:
```bash
git clone https://github.com/your-org/golden-path.git
cd golden-path
```

2. Start all services:
```bash
docker-compose up -d
```

3. Access the services:
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100
- **Tempo**: http://localhost:3200

4. Import the unified dashboard:
   - Open Grafana at http://localhost:3000
   - Go to Dashboards → Import
   - Upload `dashboards/unified-dashboard.json`

### Using the Python Library

1. Install the library:
```bash
cd library/python
pip install -e .
```

2. Use in your application:
```python
from flask import Flask
from golden_path import ObservabilityMiddleware

app = Flask(__name__)
observability = ObservabilityMiddleware(
    service_name="my-service",
    environment="development",
    version="1.0.0"
)
observability.flask_middleware(app)

@app.route("/metrics")
def metrics():
    from flask import Response
    return Response(
        observability.metrics.get_metrics(),
        mimetype="text/plain"
    )
```

See `library/python/examples/` for more examples.

### Deploying to GCP

1. Set up Terraform variables:
```bash
cd terraform/environments/gcp
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP project details
```

2. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

3. Get service URLs:
```bash
terraform output
```

## Project Structure

```
golden-path/
├── terraform/              # Terraform modules for GCP
│   ├── modules/
│   │   ├── prometheus/
│   │   ├── loki/
│   │   ├── tempo/
│   │   └── grafana/
│   └── environments/
│       └── gcp/
├── docker-compose.yml      # Local development setup
├── dashboards/            # Grafana dashboard templates
│   └── unified-dashboard.json
├── alerts/                # Alerting rules
│   ├── prometheus-alerts.yml
│   └── loki-alerts.yml
├── library/               # Application libraries
│   └── python/
│       ├── golden_path/
│       └── examples/
└── docs/                  # Documentation
```

## Components

### Prometheus
- Metrics collection and storage
- Alert rule evaluation
- Service discovery and scraping

### Loki
- Log aggregation and storage
- LogQL query language
- Integration with Prometheus labels

### Tempo
- Distributed tracing storage
- OpenTelemetry support
- Trace correlation with logs and metrics

### Grafana
- Unified visualization
- Pre-configured data sources
- Dashboard templates
- Alerting UI

## Alerting

Default alerts are configured for:
- High error rates (>5%)
- High latency (p95 > 1s)
- Service availability (<99%)
- Critical log patterns
- Database connection errors
- And more...

See `alerts/` directory for all alert rules.

## Python Library

The Python library provides:
- **ObservabilityMiddleware**: Automatic HTTP instrumentation
- **MetricsCollector**: Prometheus metrics helpers
- **TracingCollector**: OpenTelemetry tracing
- **StructuredLogger**: JSON logging with trace correlation

### Supported Frameworks
- Flask
- FastAPI
- Custom HTTP servers

## Documentation

- [Setup Guide](docs/SETUP.md) - Detailed setup instructions
- [Usage Guide](docs/USAGE.md) - Library usage examples
- [Architecture](docs/ARCHITECTURE.md) - System architecture and design

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

MIT License - see LICENSE file for details.
