curl -X POST   https://b4qzwmv1a0.execute-api.us-east-1.amazonaws.com/prod/retgen   -H "Content-Type: application/json"   -d '{
    "query": "How has Apples total net sales changed over time?",
    "index_name": "sec-10-q-chunked"
  }'

curl -X POST "https://l3yt6xr1u6.execute-api.us-east-1.amazonaws.com/prod/completions" \
  -H "Content-Type: application/json" \
  -H "x-api-key: bZJWW7SY4j4Wxpch3xuzT3b3IWIdLvsdaewldcTF" \
  -d '{
        "model": "text-davinci-003",
        "prompt": "Say hello!"
      }'


curl -X GET "https://9ow79no9qa.execute-api.us-east-1.amazonaws.com/prod/models" \
  -H "Content-Type: application/json" \
  -H "x-api-key: bZJWW7SY4j4Wxpch3xuzT3b3IWIdLvsdaewldcTF"

curl -X GET "https://l3yt6xr1u6.execute-api.us-east-1.amazonaws.com/prod/models"  -H "Content-Type: application/json"  -H "Authorization: Bearer bZJWW7SY4j4Wxpch3xuzT3b3IWIdLvsdaewldcTF"

aws apigateway put-method \
  --rest-api-id l3yt6xr1u6 \
  --resource-id dpj6t9 \
  --http-method POST \
  --authorization-type NONE \
  --api-key-required \
  --region us-east-1

aws apigateway put-integration \
  --rest-api-id l3yt6xr1u6 \
  --resource-id dpj6t9 \
  --http-method POST \
  --type MOCK \
  --request-templates '{"application/json":"{\"statusCode\": 200}"}' \
  --region us-east-1

aws apigateway put-method-response \
  --rest-api-id l3yt6xr1u6 \
  --resource-id dpj6t9 \
  --http-method POST \
  --status-code 200 \
  --response-models '{"application/json":"Empty"}' \
  --region us-east-1

aws apigateway put-integration-response \
  --rest-api-id l3yt6xr1u6 \
  --resource-id dpj6t9 \
  --http-method POST \
  --status-code 200 \
  --selection-pattern "" \
  --response-templates '{
    "application/json": "{\"id\":\"mock-completion-001\",\"object\":\"text_completion\",\"created\":1679999999,\"model\":\"mock-model\",\"choices\":[{\"text\":\"Hello, world! This is a static response from a mock integration.\",\"index\":0,\"logprobs\":null,\"finish_reason\":\"stop\"}],\"usage\":{\"prompt_tokens\":5,\"completion_tokens\":5,\"total_tokens\":10}}"
  }' \
  --region us-east-1

aws apigateway create-deployment \
  --rest-api-id l3yt6xr1u6 \
  --stage-name prod \
  --region us-east-1



aws apigateway create-api-key \
  --name "openai-mock-api-key" \
  --description "API key for openai-mock" \
  --enabled \
  --region us-east-1

aws apigateway create-usage-plan-key \
  --usage-plan-id isms72 \
  --key-id ydq3co8gb1 \
  --key-type "API_KEY" \
  --region us-east-1

aws apigateway get-usage-plan-keys --usage-plan-id isms72 --region us-east-1


# Replace these with your actual API Gateway IDs:
REST_API_ID="l3yt6xr1u6"
RESOURCE_ID="qlh8k0"
HTTP_METHOD="GET"
STATUS_CODE="200"
