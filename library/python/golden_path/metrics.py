"""
Metrics collection using Prometheus client library.
"""

from typing import Dict, Optional, Any
from prometheus_client import Counter, Histogram, Gauge, Info, generate_latest
from prometheus_client.core import CollectorRegistry
import time


class MetricsCollector:
    """
    Prometheus metrics collector with standardized labels.
    """

    def __init__(
        self,
        service_name: str,
        environment: str = "production",
        version: str = "unknown",
        registry: Optional[CollectorRegistry] = None,
    ):
        """
        Initialize metrics collector.

        Args:
            service_name: Name of the service
            environment: Environment (production, staging, development)
            version: Service version
            registry: Optional Prometheus registry
        """
        self.service_name = service_name
        self.environment = environment
        self.version = version
        self.registry = registry or CollectorRegistry()

        # Standard labels for all metrics
        self.common_labels = {
            "service": service_name,
            "environment": environment,
            "version": version,
        }

        # HTTP request metrics
        self.http_requests_total = Counter(
            "http_requests_total",
            "Total number of HTTP requests",
            ["method", "endpoint", "status_code"],
            registry=self.registry,
        )

        self.http_request_duration_seconds = Histogram(
            "http_request_duration_seconds",
            "HTTP request duration in seconds",
            ["method", "endpoint", "status_code"],
            registry=self.registry,
            buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0),
        )

        # Business metrics
        self.business_operations_total = Counter(
            "business_operations_total",
            "Total number of business operations",
            ["operation", "status"],
            registry=self.registry,
        )

        self.business_operation_duration_seconds = Histogram(
            "business_operation_duration_seconds",
            "Business operation duration in seconds",
            ["operation"],
            registry=self.registry,
        )

        # System metrics
        self.active_connections = Gauge(
            "active_connections",
            "Number of active connections",
            registry=self.registry,
        )

        self.queue_size = Gauge(
            "queue_size",
            "Size of processing queue",
            ["queue_name"],
            registry=self.registry,
        )

        # Service info
        self.service_info = Info(
            "service_info",
            "Service information",
            registry=self.registry,
        )
        self.service_info.info(self.common_labels)

    def record_http_request(
        self,
        method: str,
        endpoint: str,
        status_code: int,
        duration: float,
    ):
        """
        Record an HTTP request.

        Args:
            method: HTTP method (GET, POST, etc.)
            endpoint: Request endpoint
            status_code: HTTP status code
            duration: Request duration in seconds
        """
        labels = [method, endpoint, str(status_code)]
        self.http_requests_total.labels(*labels).inc()
        self.http_request_duration_seconds.labels(*labels).observe(duration)

    def record_business_operation(
        self,
        operation: str,
        status: str,
        duration: Optional[float] = None,
    ):
        """
        Record a business operation.

        Args:
            operation: Operation name
            status: Operation status (success, error, etc.)
            duration: Optional operation duration in seconds
        """
        self.business_operations_total.labels(operation=operation, status=status).inc()
        if duration is not None:
            self.business_operation_duration_seconds.labels(operation=operation).observe(
                duration
            )

    def set_active_connections(self, count: int):
        """Set the number of active connections."""
        self.active_connections.set(count)

    def set_queue_size(self, queue_name: str, size: int):
        """Set the size of a processing queue."""
        self.queue_size.labels(queue_name=queue_name).set(size)

    def get_metrics(self) -> bytes:
        """Get Prometheus metrics in text format."""
        return generate_latest(self.registry)

    def create_custom_counter(
        self,
        name: str,
        description: str,
        labels: Optional[list] = None,
    ) -> Counter:
        """Create a custom counter metric."""
        return Counter(
            name,
            description,
            labels or [],
            registry=self.registry,
        )

    def create_custom_histogram(
        self,
        name: str,
        description: str,
        labels: Optional[list] = None,
        buckets: Optional[tuple] = None,
    ) -> Histogram:
        """Create a custom histogram metric."""
        return Histogram(
            name,
            description,
            labels or [],
            registry=self.registry,
            buckets=buckets or Histogram.DEFAULT_BUCKETS,
        )

    def create_custom_gauge(
        self,
        name: str,
        description: str,
        labels: Optional[list] = None,
    ) -> Gauge:
        """Create a custom gauge metric."""
        return Gauge(
            name,
            description,
            labels or [],
            registry=self.registry,
        )

