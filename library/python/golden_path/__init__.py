"""
Golden Path - Unified Observability Library

A Python library for easy integration of metrics, tracing, and logging
with Prometheus, Tempo, and Loki.
"""

__version__ = "0.1.0"

from .middleware import ObservabilityMiddleware
from .metrics import MetricsCollector
from .tracing import TracingCollector
from .logging import StructuredLogger

__all__ = [
    "ObservabilityMiddleware",
    "MetricsCollector",
    "TracingCollector",
    "StructuredLogger",
]

