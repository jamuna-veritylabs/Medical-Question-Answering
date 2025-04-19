#!/bin/bash
# Deployment script

#!/bin/bash
# scripts/deploy.sh

echo "🔧 Initializing Terraform remote state..."
cd infra/remote-state
terraform init && terraform apply -auto-approve

echo "🌍 Deploying RAG Infrastructure..."
cd ../../src/blueprints
terraform init && terraform apply -auto-approve

echo "📤 Uploading sample medical PDFs to S3..."
aws s3 cp ./examples/sample.pdf s3://rag-medical-pdf-storage/medical-reports/

echo "✅ Deployment complete! All systems go."
