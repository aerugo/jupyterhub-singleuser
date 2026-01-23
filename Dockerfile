# JupyterHub Singleuser with Marimo Extension
# For Brev Data Platform
#
# Build:
#   docker build -t ghcr.io/aerugo/jupyterhub-singleuser:latest .
#
# Push:
#   docker push ghcr.io/aerugo/jupyterhub-singleuser:latest

FROM quay.io/jupyterhub/k8s-singleuser-sample:4.3.2

LABEL maintainer="Brev Data Platform"
LABEL description="JupyterHub singleuser with Marimo and data science libraries"

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages as root so they go to system site-packages
# (not ~/.local which gets overlaid by the persistent home volume)

# Install Marimo and extension
# Note: marimo>=0.25.0 required for mo.ui.form() with dict syntax
RUN pip install --no-cache-dir \
    'marimo>=0.25.0' \
    jupyterlab-marimo \
    jupyterlab-git

# Install data science libraries
RUN pip install --no-cache-dir \
    pandas \
    numpy \
    scipy \
    scikit-learn \
    matplotlib \
    seaborn \
    plotly \
    polars \
    pyarrow \
    duckdb \
    sqlalchemy \
    psycopg2-binary

# Install cloud/storage clients
RUN pip install --no-cache-dir \
    boto3 \
    s3fs \
    lakefs-client \
    requests \
    httpx

# Install PyTorch with CUDA 12.1 support for GPU acceleration
RUN pip install --no-cache-dir \
    torch --index-url https://download.pytorch.org/whl/cu121

# Install ML/AI libraries
RUN pip install --no-cache-dir \
    transformers \
    openai \
    anthropic

# Install dashboard dependencies (for Marimo dashboards)
RUN pip install --no-cache-dir \
    'weaviate-client>=4.9.0' \
    'lakefs-sdk>=1.0.0'

# Create startup script to set up dashboards in user home directory
# This clones or updates the brev-dashboards repo in ~/dashboards (persistent, writable)
# Users can commit and push changes using the JupyterLab Git extension
RUN cat > /usr/local/bin/setup-dashboards.sh << 'SCRIPT'
#!/bin/bash
DASHBOARDS_DIR="/home/jovyan/dashboards"
REPO_URL="https://github.com/aerugo/brev-dashboards.git"

if [ ! -d "$DASHBOARDS_DIR" ]; then
    echo "Cloning brev-dashboards to $DASHBOARDS_DIR..."
    git clone "$REPO_URL" "$DASHBOARDS_DIR"
elif [ -d "$DASHBOARDS_DIR/.git" ]; then
    echo "Dashboards directory exists, fetching latest..."
    cd "$DASHBOARDS_DIR" && git fetch origin 2>/dev/null || true
else
    echo "Dashboards directory exists but is not a git repo, skipping..."
fi

exec "$@"
SCRIPT
RUN chmod +x /usr/local/bin/setup-dashboards.sh

# Switch back to jovyan user for runtime
USER jovyan

# Set working directory
WORKDIR /home/jovyan

# Expose JupyterHub singleuser port
EXPOSE 8888

# Use entrypoint to set up dashboards symlink before starting JupyterHub
ENTRYPOINT ["/usr/local/bin/setup-dashboards.sh"]
CMD ["jupyterhub-singleuser"]
