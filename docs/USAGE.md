# Usage Guide

This guide explains how to use the Golden Path Python library in your applications.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Flask Integration](#flask-integration)
- [FastAPI Integration](#fastapi-integration)
- [Custom Instrumentation](#custom-instrumentation)
- [Metrics](#metrics)
- [Tracing](#tracing)
- [Logging](#logging)
- [Advanced Configuration](#advanced-configuration)

## Basic Usage

### Quick Start

```python
from golden_path import ObservabilityMiddleware

# Initialize middleware
observability = ObservabilityMiddleware(
    service_name="my-service",
    environment="production",
    version="1.0.0"
)

# Use with your framework (see framework-specific sections)
```

## Flask Integration

### Basic Setup

```python
from flask import Flask, jsonify
from golden_path import ObservabilityMiddleware

app = Flask(__name__)

# Initialize and register middleware
observability = ObservabilityMiddleware(
    service_name="flask-app",
    environment="development",
    version="1.0.0"
)
observability.flask_middleware(app)

@app.route("/")
def hello():
    return jsonify({"message": "Hello, World!"})

@app.route("/metrics")
def metrics():
    """Expose Prometheus metrics endpoint."""
    from flask import Response
    return Response(
        observability.metrics.get_metrics(),
        mimetype="text/plain"
    )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
```

### Custom Metrics

```python
from golden_path import ObservabilityMiddleware

observability = ObservabilityMiddleware(...)

@app.route("/process")
def process():
    # Record custom business metric
    observability.metrics.record_business_operation(
        operation="process_order",
        status="success",
        duration=0.5
    )
    return jsonify({"status": "processed"})
```

## FastAPI Integration

### Basic Setup

```python
from fastapi import FastAPI
from golden_path import ObservabilityMiddleware

app = FastAPI(title="My API")

# Initialize and register middleware
observability = ObservabilityMiddleware(
    service_name="fastapi-app",
    environment="development",
    version="1.0.0"
)
observability.fastapi_middleware(app)

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}

@app.get("/metrics")
def metrics():
    """Expose Prometheus metrics endpoint."""
    from fastapi.responses import Response
    return Response(
        content=observability.metrics.get_metrics(),
        media_type="text/plain"
    )
```

## Custom Instrumentation

### Using Decorators

```python
from golden_path import ObservabilityMiddleware

observability = ObservabilityMiddleware(...)

@observability.decorator
def process_order(order_id: str):
    """This function will be automatically instrumented."""
    # Your business logic here
    return {"order_id": order_id, "status": "processed"}
```

### Manual Span Creation

```python
from golden_path import ObservabilityMiddleware

observability = ObservabilityMiddleware(...)

def complex_operation():
    with observability.tracing.span("complex_operation") as span:
        # Add attributes
        observability.tracing.set_attribute(span, "operation.type", "batch")
        
        # Your code here
        result = do_work()
        
        # Add event
        observability.tracing.add_event(
            span,
            "operation.completed",
            {"items_processed": len(result)}
        )
        
        return result
```

## Metrics

### Recording HTTP Metrics

HTTP metrics are automatically recorded by the middleware, but you can also record them manually:

```python
import time

start_time = time.time()
# ... your code ...
duration = time.time() - start_time

observability.metrics.record_http_request(
    method="POST",
    endpoint="/api/orders",
    status_code=200,
    duration=duration
)
```

### Recording Business Metrics

```python
# Record operation success
observability.metrics.record_business_operation(
    operation="send_email",
    status="success",
    duration=0.1
)

# Record operation failure
observability.metrics.record_business_operation(
    operation="send_email",
    status="error",
    duration=0.05
)
```

### Custom Metrics

```python
# Create a custom counter
error_counter = observability.metrics.create_custom_counter(
    name="custom_errors_total",
    description="Total number of custom errors",
    labels=["error_type"]
)

error_counter.labels(error_type="validation").inc()

# Create a custom histogram
latency_histogram = observability.metrics.create_custom_histogram(
    name="custom_latency_seconds",
    description="Custom operation latency",
    labels=["operation"]
)

latency_histogram.labels(operation="transform").observe(0.5)

# Create a custom gauge
queue_size = observability.metrics.create_custom_gauge(
    name="custom_queue_size",
    description="Size of custom queue",
    labels=["queue_name"]
)

queue_size.labels(queue_name="processing").set(42)
```

### System Metrics

```python
# Set active connections
observability.metrics.set_active_connections(150)

# Set queue size
observability.metrics.set_queue_size("email_queue", 25)
```

## Tracing

### Creating Spans

```python
# Simple span
with observability.tracing.span("database_query"):
    result = db.query("SELECT * FROM users")

# Span with attributes
with observability.tracing.span(
    "process_payment",
    attributes={"payment_method": "credit_card", "amount": 100.0}
) as span:
    process_payment()
    
    # Add event during span
    observability.tracing.add_event(
        span,
        "payment.authorized",
        {"authorization_code": "ABC123"}
    )
```

### Getting Trace Context

```python
# Get current trace ID
trace_id = observability.tracing.get_trace_id()

# Get current span ID
span_id = observability.tracing.get_span_id()

# Get current span
span = observability.tracing.get_current_span()
if span:
    observability.tracing.set_attribute(span, "custom.attribute", "value")
```

### Error Handling in Spans

```python
with observability.tracing.span("risky_operation") as span:
    try:
        risky_code()
    except Exception as e:
        # Exception is automatically recorded
        raise
```

## Logging

### Basic Logging

```python
from golden_path import StructuredLogger

logger = StructuredLogger(
    service_name="my-service",
    environment="production",
    version="1.0.0"
)

logger.info("User logged in", user_id="123", ip_address="192.168.1.1")
logger.error("Failed to process order", order_id="456", error="timeout")
```

### Logging with Trace Correlation

When using with the middleware, logs automatically include trace IDs:

```python
# This log will automatically include trace_id and span_id
logger.info("Processing request", request_id="789")
```

### Log Context

Use log context for adding fields to multiple logs:

```python
log_ctx = logger.with_fields(user_id="123", session_id="abc")

log_ctx.info("User action", action="click")
log_ctx.info("User action", action="submit")
# Both logs will include user_id and session_id
```

### Log Levels

```python
logger.debug("Debug information", detail="value")
logger.info("Informational message", key="value")
logger.warning("Warning message", issue="description")
logger.error("Error occurred", error="details")
logger.critical("Critical error", error="details")
```

## Advanced Configuration

### Custom Endpoints

```python
from golden_path import ObservabilityMiddleware, TracingCollector

# Custom Tempo endpoint
tracing = TracingCollector(
    service_name="my-service",
    tempo_endpoint="https://tempo.example.com:4317"
)

observability = ObservabilityMiddleware(
    service_name="my-service",
    environment="production",
    version="1.0.0",
    tracing_collector=tracing
)
```

### Custom Metrics Registry

```python
from prometheus_client import CollectorRegistry
from golden_path import MetricsCollector, ObservabilityMiddleware

# Custom registry
registry = CollectorRegistry()

metrics = MetricsCollector(
    service_name="my-service",
    environment="production",
    version="1.0.0",
    registry=registry
)

observability = ObservabilityMiddleware(
    service_name="my-service",
    environment="production",
    version="1.0.0",
    metrics_collector=metrics
)
```

### Disable Trace Correlation in Logs

```python
from golden_path import StructuredLogger

logger = StructuredLogger(
    service_name="my-service",
    environment="production",
    version="1.0.0",
    enable_trace_correlation=False  # Disable automatic trace correlation
)
```

## Best Practices

1. **Service Naming**: Use consistent service names across all environments
2. **Labels**: Use standard labels (service, environment, version) consistently
3. **Error Handling**: Always record errors in metrics and logs
4. **Trace Context**: Propagate trace context across service boundaries
5. **Metrics Endpoint**: Always expose `/metrics` endpoint for Prometheus scraping
6. **Log Structure**: Use structured logging with consistent field names

## Examples

See the `library/python/examples/` directory for complete working examples:
- `flask_example.py` - Flask application
- `fastapi_example.py` - FastAPI application
- `basic_example.py` - Basic usage patterns

