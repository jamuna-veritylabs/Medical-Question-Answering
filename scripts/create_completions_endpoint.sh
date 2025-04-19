#!/bin/bash
#
# create_chat_completions_endpoint.sh
#
# Creates (or updates) a /chat/completions endpoint in API Gateway (REST API) 
# with request/response schemas that mimic OpenAI's Chat Completions API.
# The endpoint uses a MOCK integration for demonstration purposes.
# 
# Usage:
#   ./create_chat_completions_endpoint.sh
#

# -----------------------------
# 1) Configuration
# -----------------------------
REGION="us-east-1"
API_ID="9ow79no9qa"

# Schema names in API Gateway
REQUEST_MODEL_NAME="OpenAiChatCompletionRequest"
RESPONSE_MODEL_NAME="OpenAiChatCompletionResponse"

# JSON Schemas for the Request and Response
# (Simplified examples based on OpenAI Chat Completions format)
REQUEST_SCHEMA='{
  "type": "object",
  "properties": {
    "model": { "type": "string" },
    "messages": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "role": { "type": "string" },
          "content": { "type": "string" }
        },
        "required": ["role", "content"]
      }
    },
    "temperature": { "type": "number" },
    "top_p": { "type": "number" },
    "n": { "type": "integer" },
    "stream": { "type": "boolean" },
    "stop": { "type": ["string", "array"] },
    "max_tokens": { "type": "integer" }
  },
  "required": ["model","messages"]
}'

RESPONSE_SCHEMA='{
  "type": "object",
  "properties": {
    "id": { "type": "string" },
    "object": { "type": "string" },
    "created": { "type": "integer" },
    "choices": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "index": { "type": "integer" },
          "message": {
            "type": "object",
            "properties": {
              "role": { "type": "string" },
              "content": { "type": "string" }
            },
            "required": ["role","content"]
          },
          "finish_reason": { "type": "string" }
        },
        "required": ["index","message","finish_reason"]
      }
    },
    "usage": {
      "type": "object",
      "properties": {
        "prompt_tokens": { "type": "integer" },
        "completion_tokens": { "type": "integer" },
        "total_tokens": { "type": "integer" }
      },
      "required": ["prompt_tokens","completion_tokens","total_tokens"]
    }
  },
  "required": ["id","object","created","choices","usage"]
}'

# Example static response (mock) in OpenAI Chat Completions format
STATIC_RESPONSE='{
  "id": "chatcmpl-7fH0qB2zT2EXAMPLE",
  "object": "chat.completion",
  "created": 1677652288,
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Hello! This is a mock response."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 7,
    "total_tokens": 17
  }
}'

# -----------------------------
# 2) Helper: Create or Update a Model
# -----------------------------
create_or_update_model() {
  local MODEL_NAME="$1"
  local SCHEMA_JSON="$2"
  
  # Check if model already exists
  EXISTING_MODEL=$(aws apigateway get-models --rest-api-id "$API_ID" --region "$REGION" --query "items[?name=='${MODEL_NAME}'].id" --output text)
  
  if [ "$EXISTING_MODEL" = "None" ]; then
    echo "Creating model: $MODEL_NAME"
    aws apigateway create-model \
      --rest-api-id "$API_ID" \
      --name "$MODEL_NAME" \
      --content-type "application/json" \
      --schema "$SCHEMA_JSON" \
      --region "$REGION" >/dev/null
  else
    echo "Model $MODEL_NAME already exists. Updating..."
    aws apigateway update-model \
      --rest-api-id "$API_ID" \
      --model-name "$MODEL_NAME" \
      --patch-operations op=replace,path=/schema,value="$SCHEMA_JSON" \
      --region "$REGION" >/dev/null
  fi
}

# -----------------------------
# 3) Get the Root Resource ID ("/")
# -----------------------------
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --region "$REGION" \
  --query "items[?path=='/'].id" \
  --output text)

if [ -z "$ROOT_RESOURCE_ID" ] || [ "$ROOT_RESOURCE_ID" = "None" ]; then
  echo "Error: Could not retrieve the root resource ID."
  exit 1
fi

echo "Root resource ID: $ROOT_RESOURCE_ID"

# -----------------------------
# 4) Create or Find /chat
# -----------------------------
CHAT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --region "$REGION" \
  --query "items[?path=='/chat'].id" \
  --output text)

if [ "$CHAT_RESOURCE_ID" = "None" ]; then
  echo "Creating /chat resource..."
  CREATE_CHAT_OUTPUT=$(aws apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$ROOT_RESOURCE_ID" \
    --path-part chat \
    --region "$REGION")
  CHAT_RESOURCE_ID=$(echo "$CREATE_CHAT_OUTPUT" | jq -r '.id')
  echo "Created /chat with ID: $CHAT_RESOURCE_ID"
else
  echo "/chat already exists with ID: $CHAT_RESOURCE_ID"
fi

# -----------------------------
# 5) Create or Find /chat/completions
# -----------------------------
COMPLETIONS_PATH="/chat/completions"
COMPLETIONS_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --region "$REGION" \
  --query "items[?path=='${COMPLETIONS_PATH}'].id" \
  --output text)

if [ "$COMPLETIONS_RESOURCE_ID" = "None" ]; then
  echo "Creating /chat/completions resource..."
  CREATE_COMPLETIONS_OUTPUT=$(aws apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$CHAT_RESOURCE_ID" \
    --path-part completions \
    --region "$REGION")
  COMPLETIONS_RESOURCE_ID=$(echo "$CREATE_COMPLETIONS_OUTPUT" | jq -r '.id')
  echo "Created /chat/completions with ID: $COMPLETIONS_RESOURCE_ID"
else
  echo "/chat/completions already exists with ID: $COMPLETIONS_RESOURCE_ID"
fi

# -----------------------------
# 6) Create or Update the Models for Request/Response
# -----------------------------
create_or_update_model "$REQUEST_MODEL_NAME"  "$REQUEST_SCHEMA"
create_or_update_model "$RESPONSE_MODEL_NAME" "$RESPONSE_SCHEMA"

# -----------------------------
# 7) Put the POST Method (request validation with request model)
# -----------------------------
# Authorization: NONE for simplicity. Adjust as needed (e.g., AWS_IAM, COGNITO_USER_POOLS).
# This method requires the request to be "application/json" and uses our OpenAiChatCompletionRequest model.
echo "Setting up POST method for /chat/completions..."

aws apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$COMPLETIONS_RESOURCE_ID" \
  --http-method POST \
  --authorization-type NONE \
  --region "$REGION" \
  --request-validator-id "NONE" 2>/dev/null || true

# If you want to enforce request validation against the model, you must create or find a Request Validator ID 
# and use that instead of "NONE". For simplicity, we skip strict validation here.

# Associate the request model with the POST method
aws apigateway update-method \
  --rest-api-id "$API_ID" \
  --resource-id "$COMPLETIONS_RESOURCE_ID" \
  --http-method POST \
  --patch-operations op=replace,path=/requestModels/application~1json,value="$REQUEST_MODEL_NAME" \
  --region "$REGION"

# -----------------------------
# 8) Put a MOCK Integration
# -----------------------------
echo "Creating MOCK integration for POST /chat/completions..."

aws apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$COMPLETIONS_RESOURCE_ID" \
  --http-method POST \
  --type MOCK \
  --request-templates '{"application/json":"{\"statusCode\": 200}"}' \
  --region "$REGION" >/dev/null

# -----------------------------
# 9) Define Method Response (200) referencing the response model
# -----------------------------
echo "Defining method response for 200..."

aws apigateway put-method-response \
  --rest-api-id "$API_ID" \
  --resource-id "$COMPLETIONS_RESOURCE_ID" \
  --http-method POST \
  --status-code 200 \
  --response-models "{\"application/json\":\"$RESPONSE_MODEL_NAME\"}" \
  --region "$REGION" >/dev/null

# -----------------------------
# 10) Define Integration Response (200) with static JSON
# -----------------------------
echo "Defining integration response with static OpenAI-style JSON..."

aws apigateway put-integration-response \
  --rest-api-id "$API_ID" \
  --resource-id "$COMPLETIONS_RESOURCE_ID" \
  --http-method POST \
  --status-code 200 \
  --selection-pattern "" \
  --response-templates "{\"application/json\":\"$STATIC_RESPONSE\"}" \
  --region "$REGION" >/dev/null

# -----------------------------
# 11) Deploy the API to 'prod'
# -----------------------------
echo "Deploying API to stage: prod..."

DEPLOYMENT_OUTPUT=$(aws apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name prod \
  --region "$REGION")

DEPLOYMENT_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.id')

if [ -z "$DEPLOYMENT_ID" ] || [ "$DEPLOYMENT_ID" = "null" ]; then
  echo "Error: Failed to deploy the API."
  exit 1
fi

echo "Deployment created with ID: $DEPLOYMENT_ID"
echo "Endpoint available at: https://$API_ID.execute-api.$REGION.amazonaws.com/prod/chat/completions"
