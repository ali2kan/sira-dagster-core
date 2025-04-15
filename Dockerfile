# Dagster libraries to run both dagster-webserver and the dagster-daemon. Does not
# need to have access to any pipeline code.

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim as builder

# Add build argument to optionally install dev dependencies
ARG INSTALL_DEV=false

# Set up working directory
WORKDIR /opt/dagster/app

# First copy dependency files for better caching
COPY pyproject.toml ./
# Check if uv.lock exists and copy if available
COPY uv.lock* ./

# Install all dependencies from pyproject.toml but not the project itself
ENV UV_SYSTEM_PYTHON=1
RUN --mount=type=cache,target=/root/.cache/uv \
    if [ "$INSTALL_DEV" = "true" ]; then \
    uv pip install --system -r pyproject.toml -r pyproject.toml[dev]; \
    else \
    uv pip install --system -r pyproject.toml; \
    fi

# Copy the rest of the application code
COPY . .

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    git \
    && ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
    && echo "UTC" > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory and environment
WORKDIR /opt/dagster/app
ENV PYTHONPATH=/opt/dagster/app
ENV UV_SYSTEM_PYTHON=1

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Set $DAGSTER_HOME and copy dagster instance and workspace YAML there
ENV DAGSTER_HOME=/opt/dagster/dagster_home/

# Create necessary directories
RUN mkdir -p $DAGSTER_HOME

# Copy application code
COPY . .

# Verify installation and executable paths
RUN python -c "import dagster; print(f'Dagster version: {dagster.__version__}')" && \
    dagster --version

WORKDIR $DAGSTER_HOME
