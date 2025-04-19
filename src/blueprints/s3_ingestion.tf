# src/blueprints/vector_db.tf

resource "aws_opensearch_domain" "rag_vector_store" {
  domain_name           = "rag-vector-store"
  engine_version        = "OpenSearch_2.11"
  region                = "us-east-1"

  cluster_config {
    instance_type = "t3.small.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  access_policies = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "es:*",
      Resource = "*"
    }]
  })

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https = true
  }

  tags = {
    Name = "RAG-KNN-VectorStore"
  }
}
