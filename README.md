# JupyterHub Singleuser with Marimo

Custom JupyterHub singleuser image with Marimo and data science libraries pre-installed.

## Image

```
ghcr.io/aerugo/jupyterhub-singleuser:latest
```

## Included Libraries

### Notebooks
- Marimo (reactive notebooks)
- JupyterLab with Marimo extension

### Data Science
- pandas, polars, numpy, scipy
- scikit-learn
- matplotlib, seaborn, plotly
- duckdb, pyarrow

### ML/AI
- PyTorch (CPU)
- transformers
- openai, anthropic clients

### Storage
- boto3, s3fs (S3/MinIO)
- lakefs-client

## Local Build

```bash
docker build -t ghcr.io/aerugo/jupyterhub-singleuser:latest .
```

## CI/CD

Images are automatically built and pushed to GitHub Container Registry on every push to `main`.
