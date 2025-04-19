# Use an official Python slim image as a base.
FROM public.ecr.aws/docker/library/python:3.9-slim

# Set the working directory in the container.
WORKDIR /app

# Copy the requirements file and install dependencies.
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the entire repository into the container.
COPY . .

# Set PYTHONPATH so that the src folder is discoverable.
ENV PYTHONPATH="/app/src"

# Set a default FastAPI app module. This can be overridden via an environment variable.
# For example, for ingestion, you might use: "src/components/rag_ingestion.ingestion_api:app"
ENV FASTAPI_APP="src/api/main:app"

# Expose port 80.
EXPOSE 80

CMD ["sh", "-c", "uvicorn ${FASTAPI_APP} --host 0.0.0.0 --port 80 --log-level debug"]


