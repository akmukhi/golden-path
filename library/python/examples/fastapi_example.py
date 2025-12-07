"""
Example FastAPI application using Golden Path observability.
"""

from fastapi import FastAPI
from golden_path import ObservabilityMiddleware

app = FastAPI(title="Example FastAPI App")

# Initialize observability middleware
observability = ObservabilityMiddleware(
    service_name="example-fastapi-app",
    environment="development",
    version="1.0.0",
)

# Register middleware
observability.fastapi_middleware(app)


@app.get("/")
def read_root():
    return {"message": "Hello, World!"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/metrics")
def metrics():
    """Expose Prometheus metrics."""
    from fastapi.responses import Response
    return Response(
        content=observability.metrics.get_metrics(),
        media_type="text/plain",
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

