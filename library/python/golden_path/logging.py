"""
Structured logging with trace correlation.
"""

import json
import logging
import sys
from typing import Optional, Dict, Any
from datetime import datetime


class StructuredLogger:
    """
    Structured logger that correlates logs with traces.
    """

    def __init__(
        self,
        service_name: str,
        environment: str = "production",
        version: str = "unknown",
        log_level: str = "INFO",
        enable_trace_correlation: bool = True,
    ):
        """
        Initialize structured logger.

        Args:
            service_name: Name of the service
            environment: Environment (production, staging, development)
            version: Service version
            log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            enable_trace_correlation: Enable trace ID correlation
        """
        self.service_name = service_name
        self.environment = environment
        self.version = version
        self.enable_trace_correlation = enable_trace_correlation

        # Set up logger
        self.logger = logging.getLogger(service_name)
        self.logger.setLevel(getattr(logging, log_level.upper()))

        # Remove existing handlers
        self.logger.handlers = []

        # Add console handler with JSON formatter
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(StructuredFormatter())
        self.logger.addHandler(handler)

        # Prevent propagation to root logger
        self.logger.propagate = False

    def _get_trace_context(self) -> Dict[str, Optional[str]]:
        """Get trace context from OpenTelemetry if available."""
        if not self.enable_trace_correlation:
            return {}

        try:
            from opentelemetry import trace

            span = trace.get_current_span()
            if span:
                span_context = span.get_span_context()
                return {
                    "trace_id": format(span_context.trace_id, "032x"),
                    "span_id": format(span_context.span_id, "016x"),
                }
        except Exception:
            pass

        return {}

    def _log(
        self,
        level: int,
        message: str,
        extra: Optional[Dict[str, Any]] = None,
        exc_info: Optional[Any] = None,
    ):
        """Internal logging method with structured data."""
        log_data = {
            "service": self.service_name,
            "environment": self.environment,
            "version": self.version,
            "message": message,
        }

        # Add trace context
        if self.enable_trace_correlation:
            log_data.update(self._get_trace_context())

        # Add extra fields
        if extra:
            log_data.update(extra)

        self.logger.log(level, json.dumps(log_data), exc_info=exc_info)

    def debug(self, message: str, **kwargs):
        """Log debug message."""
        self._log(logging.DEBUG, message, kwargs)

    def info(self, message: str, **kwargs):
        """Log info message."""
        self._log(logging.INFO, message, kwargs)

    def warning(self, message: str, **kwargs):
        """Log warning message."""
        self._log(logging.WARNING, message, kwargs)

    def error(self, message: str, **kwargs):
        """Log error message."""
        self._log(logging.ERROR, message, kwargs, exc_info=True)

    def critical(self, message: str, **kwargs):
        """Log critical message."""
        self._log(logging.CRITICAL, message, kwargs, exc_info=True)

    def with_fields(self, **fields) -> "LogContext":
        """Create a log context with additional fields."""
        return LogContext(self, fields)


class LogContext:
    """Context manager for adding fields to all logs."""

    def __init__(self, logger: StructuredLogger, fields: Dict[str, Any]):
        self.logger = logger
        self.fields = fields

    def debug(self, message: str, **kwargs):
        """Log debug message with context fields."""
        self.logger.debug(message, **{**self.fields, **kwargs})

    def info(self, message: str, **kwargs):
        """Log info message with context fields."""
        self.logger.info(message, **{**self.fields, **kwargs})

    def warning(self, message: str, **kwargs):
        """Log warning message with context fields."""
        self.logger.warning(message, **{**self.fields, **kwargs})

    def error(self, message: str, **kwargs):
        """Log error message with context fields."""
        self.logger.error(message, **{**self.fields, **kwargs})

    def critical(self, message: str, **kwargs):
        """Log critical message with context fields."""
        self.logger.critical(message, **{**self.fields, **kwargs})


class StructuredFormatter(logging.Formatter):
    """JSON formatter for structured logging."""

    def format(self, record: logging.LogRecord) -> str:
        """Format log record as JSON."""
        # If the message is already JSON, return it
        try:
            json.loads(record.getMessage())
            return record.getMessage()
        except (json.JSONDecodeError, ValueError):
            pass

        # Otherwise, create structured log
        log_data = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }

        # Add exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        # Add extra fields from record
        for key, value in record.__dict__.items():
            if key not in [
                "name",
                "msg",
                "args",
                "created",
                "filename",
                "funcName",
                "levelname",
                "levelno",
                "lineno",
                "module",
                "msecs",
                "message",
                "pathname",
                "process",
                "processName",
                "relativeCreated",
                "thread",
                "threadName",
                "exc_info",
                "exc_text",
                "stack_info",
            ]:
                log_data[key] = value

        return json.dumps(log_data)

