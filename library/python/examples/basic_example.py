"""
Basic example of using Golden Path observability components.
"""

from golden_path import MetricsCollector, TracingCollector, StructuredLogger

# Initialize components
metrics = MetricsCollector(
    service_name="example-service",
    environment="development",
    version="1.0.0",
)

tracing = TracingCollector(
    service_name="example-service",
    environment="development",
    version="1.0.0",
    tempo_endpoint="http://localhost:4317",
)

logger = StructuredLogger(
    service_name="example-service",
    environment="development",
    version="1.0.0",
)


def process_order(order_id: str):
    """Example business function with observability."""
    with tracing.span("process_order", attributes={"order_id": order_id}):
        logger.info("Processing order", order_id=order_id)

        # Simulate work
        import time
        time.sleep(0.1)

        # Record business metric
        metrics.record_business_operation("process_order", "success", 0.1)

        logger.info("Order processed successfully", order_id=order_id)
        return {"order_id": order_id, "status": "processed"}


if __name__ == "__main__":
    # Process some orders
    for i in range(5):
        process_order(f"order-{i}")

    # Print metrics
    print("\nMetrics:")
    print(metrics.get_metrics().decode())

