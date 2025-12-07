# Architecture Documentation

This document describes the architecture and design decisions of the Golden Path observability stack.

## Overview

Golden Path provides a unified observability solution that integrates metrics, logs, and traces into a single cohesive system. The architecture is designed to be:

- **Modular**: Each component can be deployed independently
- **Scalable**: Components can scale horizontally
- **Correlated**: Metrics, logs, and traces are automatically correlated
- **Standards-based**: Uses industry-standard protocols and formats

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Applications                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │ Service A│  │ Service B│  │ Service C│                 │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                 │
│       │             │             │                        │
│       └─────────────┴─────────────┘                        │
│                    │                                        │
│         Golden Path Python Library                          │
│         (Metrics, Tracing, Logging)                        │
└────────────────────┼────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │Prometheus│  │  Loki   │  │  Tempo  │
   │(Metrics)│  │ (Logs)  │  │(Traces) │
   └────┬────┘  └────┬────┘  └────┬────┘
        │            │            │
        └────────────┴────────────┘
                     │
                     ▼
              ┌──────────┐
              │  Grafana │
              │(Visualize)│
              └──────────┘
```

## Components

### Prometheus

**Purpose**: Metrics collection and storage

**Key Features**:
- Pull-based metrics collection
- Time-series database
- PromQL query language
- Alert rule evaluation

**Data Flow**:
1. Applications expose metrics at `/metrics` endpoint
2. Prometheus scrapes metrics at configured intervals
3. Metrics stored in time-series format
4. Queries executed via PromQL

**Storage**:
- Local storage for development (Docker volumes)
- Cloud Storage for GCP deployment

### Loki

**Purpose**: Log aggregation and storage

**Key Features**:
- Push-based log ingestion
- Label-based indexing (similar to Prometheus)
- LogQL query language
- Efficient storage with compression

**Data Flow**:
1. Applications send logs to Loki via HTTP API
2. Logs indexed by labels (service, environment, etc.)
3. Logs stored in chunks
4. Queries executed via LogQL

**Storage**:
- Local filesystem for development
- Cloud Storage for GCP deployment

### Tempo

**Purpose**: Distributed tracing storage

**Key Features**:
- OpenTelemetry protocol support
- Trace correlation with logs and metrics
- Efficient trace storage
- Service map generation

**Data Flow**:
1. Applications send traces via OTLP (gRPC or HTTP)
2. Traces stored in blocks
3. Traces queryable by trace ID
4. Service maps generated from trace data

**Storage**:
- Local filesystem for development
- Cloud Storage for GCP deployment

### Grafana

**Purpose**: Visualization and dashboards

**Key Features**:
- Unified visualization for metrics, logs, and traces
- Pre-configured data sources
- Dashboard templates
- Alerting UI

**Data Sources**:
- Prometheus (metrics)
- Loki (logs)
- Tempo (traces)

**Correlation**:
- Traces to Logs: Via trace ID in log fields
- Traces to Metrics: Via service labels
- Logs to Traces: Via trace ID correlation

## Python Library Architecture

### Components

1. **ObservabilityMiddleware**
   - Main entry point
   - Coordinates metrics, tracing, and logging
   - Framework-specific integrations

2. **MetricsCollector**
   - Prometheus client wrapper
   - Standardized metric definitions
   - Custom metric creation

3. **TracingCollector**
   - OpenTelemetry integration
   - Span creation and management
   - Trace context propagation

4. **StructuredLogger**
   - JSON-formatted logs
   - Trace correlation
   - Context management

### Integration Points

```
Application Code
    │
    ├─→ ObservabilityMiddleware
    │       │
    │       ├─→ MetricsCollector → Prometheus
    │       ├─→ TracingCollector → Tempo (OTLP)
    │       └─→ StructuredLogger → Loki (HTTP)
    │
    └─→ Framework Middleware (Flask, FastAPI)
```

## Design Decisions

### 1. OpenTelemetry for Tracing

**Decision**: Use OpenTelemetry for distributed tracing

**Rationale**:
- Industry standard
- Vendor-agnostic
- Wide language support
- Future-proof

**Alternatives Considered**:
- Jaeger (vendor-specific)
- Zipkin (less feature-rich)

### 2. Prometheus Metrics Format

**Decision**: Use Prometheus metrics format

**Rationale**:
- Industry standard
- Wide tooling support
- Efficient storage
- Powerful query language

**Alternatives Considered**:
- StatsD (less powerful querying)
- InfluxDB (different use case)

### 3. Label-Based Correlation

**Decision**: Use labels for correlation between metrics, logs, and traces

**Rationale**:
- Efficient querying
- Flexible filtering
- Standard approach
- Works across all components

**Standard Labels**:
- `service`: Service name
- `environment`: Environment (production, staging, dev)
- `version`: Service version

### 4. Trace ID Correlation

**Decision**: Include trace ID in logs for correlation

**Rationale**:
- Enables log-to-trace navigation
- Standard practice
- Automatic with OpenTelemetry

**Implementation**:
- Trace ID automatically added to structured logs
- Queryable in Loki via LogQL
- Clickable links in Grafana

### 5. Terraform Modules

**Decision**: Use Terraform for infrastructure

**Rationale**:
- Infrastructure as Code
- Reproducible deployments
- Version controlled
- Multi-cloud potential

**Module Structure**:
- Reusable modules for each component
- Environment-specific configurations
- Clear separation of concerns

### 6. Docker Compose for Local Dev

**Decision**: Use Docker Compose for local development

**Rationale**:
- Easy setup
- Consistent with production
- Isolated environment
- Quick iteration

## Data Flow

### Metrics Flow

```
Application → /metrics endpoint → Prometheus scrape → Storage → Grafana
```

### Logs Flow

```
Application → StructuredLogger → HTTP POST → Loki → Storage → Grafana
```

### Traces Flow

```
Application → TracingCollector → OTLP → Tempo → Storage → Grafana
```

### Correlation Flow

```
Trace ID propagated across:
  - HTTP headers (traceparent)
  - Log fields (trace_id)
  - Metric labels (via service name)
  
Grafana uses trace ID to:
  - Link traces to logs
  - Link traces to metrics
  - Generate service maps
```

## Scalability Considerations

### Horizontal Scaling

- **Prometheus**: Can be federated or use remote write
- **Loki**: Supports clustering and sharding
- **Tempo**: Supports horizontal scaling
- **Grafana**: Stateless, can scale horizontally

### Storage

- **Retention**: Configurable per component
- **Compression**: Enabled for logs and traces
- **Archival**: Can be extended to cold storage

### Performance

- **Sampling**: Can be configured for traces
- **Batch Processing**: Used for trace and log ingestion
- **Caching**: Grafana caches query results

## Security Considerations

### Authentication

- **GCP**: IAM-based access control
- **Grafana**: User authentication and authorization
- **Services**: Service account authentication

### Network Security

- **Internal Communication**: Private networks
- **External Access**: IAM-controlled
- **TLS**: Can be enabled for production

### Data Privacy

- **Log Sanitization**: Application responsibility
- **PII Handling**: Configurable filtering
- **Access Control**: Role-based in Grafana

## Monitoring the Stack

The observability stack itself should be monitored:

- **Component Health**: Health check endpoints
- **Resource Usage**: CPU, memory, storage
- **Error Rates**: Component-specific metrics
- **Latency**: Query and ingestion latency

## Future Enhancements

Potential improvements:

1. **Multi-cloud Support**: Extend Terraform modules
2. **Additional Languages**: Go, Node.js libraries
3. **Advanced Alerting**: Alertmanager integration
4. **Sampling Strategies**: Intelligent trace sampling
5. **Cost Optimization**: Storage tiering and compression
6. **Service Mesh Integration**: Istio, Linkerd support

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Tempo Documentation](https://grafana.com/docs/tempo/latest/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [OpenTelemetry Specification](https://opentelemetry.io/docs/)

