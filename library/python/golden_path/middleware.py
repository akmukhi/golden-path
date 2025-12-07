"""
HTTP middleware for automatic observability instrumentation.
"""

import time
from typing import Callable, Optional
from functools import wraps
from .metrics import MetricsCollector
from .tracing import TracingCollector
from .logging import StructuredLogger


class ObservabilityMiddleware:
    """
    HTTP middleware that automatically instruments requests with metrics, tracing, and logging.
    """

    def __init__(
        self,
        service_name: str,
        environment: str = "production",
        version: str = "unknown",
        metrics_collector: Optional[MetricsCollector] = None,
        tracing_collector: Optional[TracingCollector] = None,
        logger: Optional[StructuredLogger] = None,
    ):
        """
        Initialize observability middleware.

        Args:
            service_name: Name of the service
            environment: Environment (production, staging, development)
            version: Service version
            metrics_collector: Optional metrics collector (creates one if not provided)
            tracing_collector: Optional tracing collector (creates one if not provided)
            logger: Optional logger (creates one if not provided)
        """
        self.service_name = service_name
        self.environment = environment
        self.version = version

        self.metrics = metrics_collector or MetricsCollector(
            service_name, environment, version
        )
        self.tracing = tracing_collector or TracingCollector(
            service_name, environment, version
        )
        self.logger = logger or StructuredLogger(
            service_name, environment, version
        )

    def flask_middleware(self, app):
        """
        Register as Flask middleware.

        Args:
            app: Flask application instance
        """
        from flask import request, g

        @app.before_request
        def before_request():
            g.start_time = time.time()
            g.trace_id = self.tracing.get_trace_id()

        @app.after_request
        def after_request(response):
            duration = time.time() - g.start_time
            method = request.method
            endpoint = request.endpoint or request.path
            status_code = response.status_code

            # Record metrics
            self.metrics.record_http_request(method, endpoint, status_code, duration)

            # Log request
            self.logger.info(
                "HTTP request completed",
                method=method,
                endpoint=endpoint,
                status_code=status_code,
                duration_ms=duration * 1000,
                trace_id=g.trace_id,
            )

            return response

        return app

    def fastapi_middleware(self, app):
        """
        Register as FastAPI middleware.

        Args:
            app: FastAPI application instance
        """
        from fastapi import Request
        from starlette.middleware.base import BaseHTTPMiddleware
        from starlette.responses import Response

        # Capture outer self for use in inner class
        observability = self

        class ObservabilityHTTPMiddleware(BaseHTTPMiddleware):
            async def dispatch(self, request: Request, call_next):
                start_time = time.time()
                trace_id = observability.tracing.get_trace_id()

                # Create span for request
                from opentelemetry import trace
                with observability.tracing.span(
                    f"{request.method} {request.url.path}",
                    attributes={
                        "http.method": request.method,
                        "http.url": str(request.url),
                        "http.route": request.url.path,
                    },
                    kind=trace.SpanKind.SERVER,
                ):
                    response = await call_next(request)
                    duration = time.time() - start_time

                    # Record metrics
                    observability.metrics.record_http_request(
                        request.method,
                        request.url.path,
                        response.status_code,
                        duration,
                    )

                    # Log request
                    observability.logger.info(
                        "HTTP request completed",
                        method=request.method,
                        endpoint=request.url.path,
                        status_code=response.status_code,
                        duration_ms=duration * 1000,
                        trace_id=trace_id,
                    )

                    return response

        app.add_middleware(ObservabilityHTTPMiddleware)
        return app

    def decorator(self, func: Callable) -> Callable:
        """
        Decorator for instrumenting functions.

        Args:
            func: Function to instrument

        Returns:
            Instrumented function
        """
        @wraps(func)
        def wrapper(*args, **kwargs):
            func_name = f"{func.__module__}.{func.__name__}"
            start_time = time.time()

            with self.tracing.span(
                func_name,
                attributes={"function.name": func.__name__},
            ):
                self.logger.debug(f"Calling {func_name}")
                try:
                    result = func(*args, **kwargs)
                    duration = time.time() - start_time

                    self.metrics.record_business_operation(
                        func_name, "success", duration
                    )
                    self.logger.debug(
                        f"{func_name} completed",
                        duration_ms=duration * 1000,
                    )
                    return result
                except Exception as e:
                    duration = time.time() - start_time
                    self.metrics.record_business_operation(
                        func_name, "error", duration
                    )
                    self.logger.error(
                        f"{func_name} failed",
                        error=str(e),
                        duration_ms=duration * 1000,
                    )
                    raise

        return wrapper

