"""
Distributed tracing using OpenTelemetry.
"""

from typing import Optional, Dict, Any
from contextlib import contextmanager
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.resources import Resource
from opentelemetry.trace import Span, Tracer
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor


class TracingCollector:
    """
    OpenTelemetry tracing collector for Tempo.
    """

    def __init__(
        self,
        service_name: str,
        environment: str = "production",
        version: str = "unknown",
        tempo_endpoint: Optional[str] = None,
    ):
        """
        Initialize tracing collector.

        Args:
            service_name: Name of the service
            environment: Environment (production, staging, development)
            version: Service version
            tempo_endpoint: Tempo OTLP endpoint (default: http://localhost:4317)
        """
        self.service_name = service_name
        self.environment = environment
        self.version = version
        self.tempo_endpoint = tempo_endpoint or "http://localhost:4317"

        # Create resource with service information
        resource = Resource.create(
            {
                "service.name": service_name,
                "service.environment": environment,
                "service.version": version,
            }
        )

        # Set up tracer provider
        provider = TracerProvider(resource=resource)
        trace.set_tracer_provider(provider)

        # Add OTLP exporter
        otlp_exporter = OTLPSpanExporter(
            endpoint=self.tempo_endpoint,
            insecure=True,  # Set to False for production with TLS
        )
        provider.add_span_processor(BatchSpanProcessor(otlp_exporter))

        self.tracer: Tracer = trace.get_tracer(__name__)

        # Auto-instrument HTTP libraries
        RequestsInstrumentor().instrument()
        try:
            HTTPXClientInstrumentor().instrument()
        except Exception:
            pass  # httpx may not be installed

    def get_tracer(self) -> Tracer:
        """Get the OpenTelemetry tracer."""
        return self.tracer

    @contextmanager
    def span(
        self,
        name: str,
        attributes: Optional[Dict[str, Any]] = None,
        kind: Optional[trace.SpanKind] = None,
    ):
        """
        Create a span context manager.

        Args:
            name: Span name
            attributes: Optional span attributes
            kind: Optional span kind (SERVER, CLIENT, etc.)

        Yields:
            Span object
        """
        span = self.tracer.start_span(
            name,
            kind=kind or trace.SpanKind.INTERNAL,
        )
        if attributes:
            for key, value in attributes.items():
                span.set_attribute(key, value)

        try:
            yield span
        except Exception as e:
            span.record_exception(e)
            span.set_status(trace.Status(trace.StatusCode.ERROR, str(e)))
            raise
        finally:
            span.end()

    def add_event(self, span: Span, name: str, attributes: Optional[Dict[str, Any]] = None):
        """Add an event to a span."""
        span.add_event(name, attributes or {})

    def set_attribute(self, span: Span, key: str, value: Any):
        """Set an attribute on a span."""
        span.set_attribute(key, value)

    def get_current_span(self) -> Optional[Span]:
        """Get the current active span."""
        return trace.get_current_span()

    def get_trace_id(self) -> Optional[str]:
        """Get the current trace ID as a hex string."""
        span = self.get_current_span()
        if span:
            return format(span.get_span_context().trace_id, "032x")
        return None

    def get_span_id(self) -> Optional[str]:
        """Get the current span ID as a hex string."""
        span = self.get_current_span()
        if span:
            return format(span.get_span_context().span_id, "016x")
        return None

