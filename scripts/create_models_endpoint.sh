#!/bin/bash
# This script creates a /models endpoint for API Gateway (REST API) with ID l3yt6xr1u6 in us-east-1.
# It defines a GET method that requires an API key and returns a static JSON response ("anthropic_claude_3_haiku_v1")
# It assumes that the usage plan (and associated API key) is already set up for the prod stage.
# Save this as create_models_endpoint.sh, then run it after making it executable.

# Set your region and API ID
REGION="us-east-1"
API_ID="9ow79no9qa"

# Get the root resource ID (path = "/")
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --region "$REGION" \
  --query "items[?path=='/'].id" \
  --output text)

if [ -z "$ROOT_RESOURCE_ID" ]; then
  echo "Error: Could not retrieve the root resource ID."
  exit 1
fi

echo "Root resource ID: $ROOT_RESOURCE_ID"

# Check if a resource with pathPart "models" already exists
EXISTING_MODEL_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --region "$REGION" \
  --query "items[?path=='/models'].id" \
  --output text)

if [ -n "$EXISTING_MODEL_RESOURCE_ID" ]; then
  echo "/models resource already exists with ID: $EXISTING_MODEL_RESOURCE_ID"
  MODEL_RESOURCE_ID="$EXISTING_MODEL_RESOURCE_ID"
else
  # Create the /models resource under the root
  CREATE_RESOURCE_OUTPUT=$(aws apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$ROOT_RESOURCE_ID" \
    --path-part models \
    --region "$REGION")
  
  # Extract the new resource ID using jq
  MODEL_RESOURCE_ID=$(echo "$CREATE_RESOURCE_OUTPUT" | jq -r '.id')
  
  if [ -z "$MODEL_RESOURCE_ID" ]; then
    echo "Error: Failed to create /models resource."
    exit 1
  fi
  
  echo "Created /models resource with ID: $MODEL_RESOURCE_ID"
fi

# Create the GET method for /models with API key requirement
aws apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$MODEL_RESOURCE_ID" \
  --http-method GET \
  --authorization-type NONE \
  --api-key-required \
  --region "$REGION"

# Create a MOCK integration for GET /models
aws apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$MODEL_RESOURCE_ID" \
  --http-method GET \
  --type MOCK \
  --request-templates '{"application/json":"{\"statusCode\": 200}"}' \
  --region "$REGION"

# Create the method response for 200
aws apigateway put-method-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MODEL_RESOURCE_ID" \
  --http-method GET \
  --status-code 200 \
  --response-models '{"application/json":"Empty"}' \
  --region "$REGION"

# Create the integration response with the static value "anthropic_claude_3_haiku_v1"
aws apigateway put-integration-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MODEL_RESOURCE_ID" \
  --http-method GET \
  --status-code 200 \
  --selection-pattern "" \
  --response-templates '{"application/json": "\"anthropic_claude_3_haiku_v1\""}' \
  --region "$REGION"

# Deploy the API to the prod stage
DEPLOYMENT_OUTPUT=$(aws apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name prod \
  --region "$REGION")

DEPLOYMENT_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.id')

if [ -z "$DEPLOYMENT_ID" ]; then
  echo "Error: Failed to deploy the API."
  exit 1
fi

echo "Deployment created with ID: $DEPLOYMENT_ID"
echo "Endpoint available at: https://$API_ID.execute-api.$REGION.amazonaws.com/prod/models"
