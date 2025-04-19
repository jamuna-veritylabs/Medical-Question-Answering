# Entrypoint for Docker container

#!/bin/bash
# scripts/docker/entrypoint.sh

echo "🚀 Starting RAG Dev Container..."

# Run Jupyter by default
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''
