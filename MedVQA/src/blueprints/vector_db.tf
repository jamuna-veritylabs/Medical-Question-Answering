# src/blueprints/s3_ingestion.tf

resource "aws_s3_bucket" "medical_documents" {
  bucket = "rag-medical-pdf-storage"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Medical PDF Ingestion"
  }
}
