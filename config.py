import os
from dotenv import load_dotenv

# Load environment variables from .env file (if present)
load_dotenv()

class Config:
    # Embedding model config
    EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "sbert")  # Options: 'sbert', 'titan'

    # Vector store config
    VECTOR_DB = os.getenv("VECTOR_DB", "chroma")  # Options: 'chroma', 'faiss', 'opensearch'

    # LLM config
    LLM_PROVIDER = os.getenv("LLM_PROVIDER", "bedrock")  # Options: 'bedrock', 'hf'
    BEDROCK_MODEL = os.getenv("BEDROCK_MODEL", "anthropic.claude-v2")
    HF_MODEL = os.getenv("HF_MODEL", "google/flan-t5-large")

    # Chunking settings
    CHUNK_SIZE = int(os.getenv("CHUNK_SIZE", 500))
    CHUNK_OVERLAP = int(os.getenv("CHUNK_OVERLAP", 50))

    # ChromaDB config
    CHROMA_PERSIST_DIR = os.getenv("CHROMA_PERSIST_DIR", "./vectorstore/chroma_db")

    # OpenSearch config
    OPENSEARCH_HOST = os.getenv("OPENSEARCH_HOST", "localhost")
    OPENSEARCH_PORT = int(os.getenv("OPENSEARCH_PORT", 9200))
    OPENSEARCH_USERNAME = os.getenv("OPENSEARCH_USERNAME", "")
    OPENSEARCH_PASSWORD = os.getenv("OPENSEARCH_PASSWORD", "")

    # AWS Bedrock credentials (optional if using AWS CLI configured already)
    AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
    BEDROCK_ACCESS_KEY = os.getenv("BEDROCK_ACCESS_KEY", "")
    BEDROCK_SECRET_KEY = os.getenv("BEDROCK_SECRET_KEY", "")

    # Logging & debug
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

