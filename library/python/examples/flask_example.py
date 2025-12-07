"""
Example Flask application using Golden Path observability.
"""

from flask import Flask, jsonify
from golden_path import ObservabilityMiddleware

app = Flask(__name__)

# Initialize observability middleware
observability = ObservabilityMiddleware(
    service_name="example-flask-app",
    environment="development",
    version="1.0.0",
)

# Register middleware
observability.flask_middleware(app)


@app.route("/")
def hello():
    return jsonify({"message": "Hello, World!"})


@app.route("/health")
def health():
    return jsonify({"status": "healthy"})


@app.route("/metrics")
def metrics():
    """Expose Prometheus metrics."""
    from flask import Response
    return Response(
        observability.metrics.get_metrics(),
        mimetype="text/plain",
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

