# Dockerfile for ai-acc-stack

# scripts/docker/Dockerfile

FROM python:3.10-slim

# Set environment
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create app directory
WORKDIR /app

# Copy everything from repo
COPY ../../ /app/

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Run entrypoint
ENTRYPOINT ["bash", "scripts/docker/entrypoint.sh"]
