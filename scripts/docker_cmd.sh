
# push to aws
aws ecr create-repository --repository-name tabular --region us-east-1 
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 120569609191.dkr.ecr.us-east-1.amazonaws.com

### rag-generation
docker tag ai-acc-stack-rag-generation:latest 120569609191.dkr.ecr.us-east-1.amazonaws.com/rag-generation:latest
docker push 120569609191.dkr.ecr.us-east-1.amazonaws.com/rag-generation:latest
# aws ecs update-service --cluster rag-cluster --service rag-generation-service --force-new-deployment

# rag-ingestion
docker tag ai-acc-stack-rag_ingestion:latest 120569609191.dkr.ecr.us-east-1.amazonaws.com/rag-ingestion:latest
docker push 120569609191.dkr.ecr.us-east-1.amazonaws.com/rag-ingestion:latest
# aws ecs update-service --cluster rag-cluster --service rag-ingestion-service --force-new-deployment

### tabular
docker tag ai-acc-stack-tabular-generation:latest 120569609191.dkr.ecr.us-east-1.amazonaws.com/tabular:latest
docker push 120569609191.dkr.ecr.us-east-1.amazonaws.com/tabular:latest
# aws ecs update-service --cluster rag-cluster --service tabular-service --force-new-deployment

### verity-site
docker build -platform linux/amd64 -t verity-site-app:latest .
docker tag verity-site-app:latest 120569609191.dkr.ecr.us-east-1.amazonaws.com/verity-site:latest
docker push 120569609191.dkr.ecr.us-east-1.amazonaws.com/verity-site:latest

### tellus-openwebui
docker tag ai-acc-stack-tellus-openwebui:latest 120569609191.dkr.ecr.us-east-1.amazonaws.com/tellus-openwebui:latest
docker push 120569609191.dkr.ecr.us-east-1.amazonaws.com/tellus-openwebui:latest
# aws ecs update-service --cluster rag-cluster --service tellus-openwebui-service --force-new-deployment
aws ecs execute-command --cluster rag-cluster --task arn:aws:ecs:us-east-1:120569609191:task/rag-cluster/dd3e54712741442b9c782af2da59917c  --container tellus-openwebui --command "/bin/sh" --interactive

# reset admin password
docker run --rm -v open-webui:/data alpine/socat EXEC:"bash -c 'apk add sqlite && echo UPDATE auth SET password='\'''\'' WHERE email='\''prajwal88@gmail.com'\''; | sqlite3 /data/webui.db'", STDIO
UPDATE auth SET password='hahed paswoed' WHERE email='email';

aws ecr create-repository --repository-name unstrucutred-extraction --region us-east-1 
# docker run --memory=512m --cpus=0.25 --name rag-ingestion -p 80:80 -e FASTAPI_APP="components.rag_ingestion.ingestion_api:app" -v ~/.aws:/root/.aws 120569609191.dkr.ecr.us-east-1.amazonaws.com/rag-ingestion:latest
docker tag ai-acc-stack-unstructured_base:latest 120569609191.dkr.ecr.us-east-1.amazonaws.com/unstrucutred-extraction:latest
docker push 120569609191.dkr.ecr.us-east-1.amazonaws.com/unstrucutred-extraction:latest

# docker run -p 83:83 -e FASTAPI_APP="src/components/rag_retrieval.retrieval_api:app" ted-uns-rag-ret
# docker run -p 8083:83 -e FASTAPI_APP="src/components/rag_generation.generation_api:app" rag_generation


#Local Build
# build
docker build --platform linux/amd64 -t rag-ingestion .

# run
docker run --name 120569609191.dkr.ecr.us-east-1.amazonaws.com/rag-generation:latest -p 8084:80 \
  -e FASTAPI_APP="components.rag_ingestion.ingestion_api:app" \
  -v ~/.aws:/root/.aws \
  120569609191.dkr.ecr.us-east-1.amazonaws.com/rag-generation:latest

# test
curl -v -X POST http://localhost:80/ingest   -H "Content-Type: application/json"   -d '{
    "index_name": "test-chunked-pdf",
    "config": {
      "oss-tellus-demo": {
        "collection_name": "tellusdemo",
        "collection_host": "search-tellusdemo-jx7gunirn55qppnao47mc6xn2u.us-east-1.es.amazonaws.com",
        "service": "es",
        "region": "us-east-1",
        "log_path": "data/logs/ingestion_logs",
        "storage_type": "s3",
        "indices": {
                "test-chunked-pdf": {
                        "bucket_path": "s3://kb-tellus-demo/test/pdf/",
                        "data_type":"pdf",
                        "index_type": "basic-chunked",
                        "ingestion_type": {
                                            "type":"basic_image", # Options: basic, basic_image, unstr
                                            "chunking":"page",  # Options: paragraph, page, etc.
                                            "params":{}
                                            },
                        "embedding_model":"amazon_titan_embed_text_v2",
                        "llm_model":"anthropic_claude_3_haiku_v1",
                        "max_chars": 50000,
                        "max_token": 8000,
                        "bulk_size": 10  # Number of documents per bulk request
            }
        }
      }
    }
  }


## test fargate service
aws ecs update-service --cluster rag-cluster --service rag-ingestion-service  --desired-count 1
aws ecs describe-services --cluster rag-cluster --services rag-ingestion-service --query 'services[0].desiredCount'

# list tasks
aws ecs list-tasks --cluster rag-cluster --service-name rag-generation-service

## get IP add - "172.31.64.155"
aws ecs describe-tasks --cluster rag-cluster --tasks arn:aws:ecs:us-east-1:120569609191:task/rag-cluster/87673f18094c480d81391a1bbee4152f --query 'tasks[0].containers[0].networkInterfaces[0].privateIpv4Address'
aws ecs describe-tasks --cluster rag-cluster \
  --tasks $(aws ecs list-tasks --cluster rag-cluster  --service-name rag-generation-service --query 'taskArns[0]' --output text) \
  --query 'tasks[0].attachments[0].details' --output table

aws ec2 describe-network-interfaces --network-interface-ids  eni-0ba0e96f6f6d59292 \
  --query 'NetworkInterfaces[0].Association.PublicIp' --output text

# Step 1: Fetch the latest running Task ARN
TASK_ARN=$(aws ecs list-tasks --cluster rag-cluster --query 'taskArns[0]' --output text)

# Step 2: Extract the Private IP Address of the running Task
PRIVATE_IP=$(aws ecs describe-tasks --cluster rag-cluster --tasks $TASK_ARN \
  --query 'tasks[0].attachments[0].details[?name==`privateIPv4Address`].value' \
  --output text)

echo "🔹 Private IP of ECS Task: $PRIVATE_IP"

# Step 3: Send Ingestion Request via cURL
curl -v -X POST http://172.31.43.251/ingest -H "Content-Type: application/json" -d '{
    "index_name": "test-chunked-pdf",
    "config": {
      "oss-tellus-demo": {
        "collection_name": "tellusdemo",
        "collection_host": "search-tellusdemo-jx7gunirn55qppnao47mc6xn2u.us-east-1.es.amazonaws.com",
        "service": "es",
        "region": "us-east-1",
        "log_path": "data/logs/ingestion_logs",
        "storage_type": "s3",
        "indices": {
                "test-chunked-pdf": {
                        "bucket_path": "s3://kb-tellus-demo/test/pdf/",
                        "data_type":"pdf",
                        "index_type": "basic-chunked",
                        "ingestion_type": {
                                            "type":"basic_image",
                                            "chunking":"page",  
                                            "params":{}
                                            },
                        "embedding_model":"amazon_titan_embed_text_v2",
                        "llm_model":"anthropic_claude_3_haiku_v1",
                        "max_chars": 50000,
                        "max_token": 8000,
                        "bulk_size": 10  
            }
        }
      }
    }
  }'


curl -X GET http://54.210.127.82:80/docs
aws ecs describe-tasks --cluster rag-cluster --tasks arn:aws:ecs:us-east-1:120569609191:task/rag-cluster/13b12efdd9fa460390d38735df73f67b --query "tasks[0].attachments[0].details"



### ecs alb listener rules
ALB_ARN=arn:aws:elasticloadbalancing:us-east-1:120569609191:loadbalancer/app/app-alb/5775304fcba21b02
aws elbv2 describe-target-groups --load-balancer-arn $ALB_ARN --output table
aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --output table
aws elbv2 describe-listener-attributes --listener-arn arn:aws:elasticloadbalancing:us-east-1:120569609191:listener/app/app-alb/5775304fcba21b02/0387b1151c78fb24 --output table

### os
awscurl -u admin:Password1234% -XPUT "https://search-tellusdemo-jx7gunirn55qppnao47mc6xn2u.us-east-1.es.amazonaws.com/_plugins/_security/api/rolesmapping/all_access" \
  -d '{"users": ["arn:aws:iam::120569609191:user/prajwal88"], "backend_roles": []}' \
  -H "Content-Type: application/json"

# aws athena start-query-execution \
#   --query-string "CREATE DATABASE IF NOT EXISTS \`tellus-demo\`;" \
#   --result-configuration "OutputLocation=s3://120569609191-athena-result/"


aws cognito-idp sign-up \
  --client-id 5fi34f3tnkg3jfs7qjmeg74u0c \
  --username <<>> \
  --password <<>> \
  --user-attributes Name=email,Value=<<>>


# read -p "Enter Cognito confirmation code: " CONFIRMATION_CODE
aws cognito-idp confirm-sign-up \
  --client-id 5fi34f3tnkg3jfs7qjmeg74u0c \
  --username <<>> \
  --confirmation-code "<<>>"

### Cognito Authentication: 
aws cognito-idp initiate-auth \
  --client-id 5fi34f3tnkg3jfs7qjmeg74u0c \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters "USERNAME=prajwals@veritylabs.ai,PASSWORD=<>"


# get models
curl -X GET http://localhost:8083/services/rag-generation/models -H "Authorization: Bearer eyJraWQiOiJ2U3IyTEJselIwZno5UmdwcUNZVCtWSjhqYjNhM1VacXBPcWgreGRNVVFNPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJjNDA4ODRkOC01MGIxLTcwNTItMzJlMC1jNjc5NDM2MDMwNWQiLCJjb2duaXRvOmdyb3VwcyI6WyJmcmVlLXVzZXJzIl0sImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX2xQcEZCQVRmQiIsImNsaWVudF9pZCI6IjVmaTM0ZjN0bmtnM2pmczdxam1lZzc0dTBjIiwib3JpZ2luX2p0aSI6IjAyM2FkYWY4LTQyYjQtNDIwYi1iYzg1LTE3NzViMzU5YTc0OCIsImV2ZW50X2lkIjoiMGE4Y2ZhYjYtMmI2My00MDJhLTgzMDYtZGMzMzdjNWE5OTk1IiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJhd3MuY29nbml0by5zaWduaW4udXNlci5hZG1pbiIsImF1dGhfdGltZSI6MTc0NDU3Mzg4NCwiZXhwIjoxNzQ0NTc3NDg0LCJpYXQiOjE3NDQ1NzM4ODQsImp0aSI6ImZlNTE3ZGMyLTVmOWQtNGIxOC1iMjE4LWIxZTFhNGY2NmRhZiIsInVzZXJuYW1lIjoicHJhandhbHNAdmVyaXR5bGFicy5haSJ9.AFKWMN8BHfmURFh601K1ZjzkKKFFardc7l0kJ2N6JCFCMgGQU7pGJkbT_sl96mYOZAXNtjkWVTBTeF1hI_K9s3-KQoiKwh91UZXDbZPeDnOl6rCEDfA1ocaGvW--uo2XWc-lKKqN52feNgCQCUQ68zkJtQRPHwNyboA3L9B5wXPl33TPFO8e4bHDsC8TBtUrCghN6O-GKRBJ9lnSs2gkAHJcSmwwXVwpkvRitCV6Eow_f1B7ZW-AySti0311mY6lA9tEzqPkoJ2Z_Pgdr2cuaDwycuJi5em6MEIGpVM7AQp7SbokbZv5hrsHxNHd2nkZRHye2kD2GDxfH-0csZVp-Q"

# chat completion
  curl -X 'POST'   'https://chat.veritylabs.ai/services/rag-generation/chat/completions'   \
  -H 'accept: application/json' \
  -H "Authorization: Bearer eyJraWQiOiJ2U3IyTEJselIwZno5UmdwcUNZVCtWSjhqYjNhM1VacXBPcWgreGRNVVFNPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJjNDA4ODRkOC01MGIxLTcwNTItMzJlMC1jNjc5NDM2MDMwNWQiLCJjb2duaXRvOmdyb3VwcyI6WyJmcmVlLXVzZXJzIl0sImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX2xQcEZCQVRmQiIsImNsaWVudF9pZCI6IjVmaTM0ZjN0bmtnM2pmczdxam1lZzc0dTBjIiwib3JpZ2luX2p0aSI6Ijg4MWFhMDE4LTEzYjYtNGU3OC1hMjFjLThiNjU4Y2IwN2NjNyIsImV2ZW50X2lkIjoiNmY1YWM1ZDctZDU1ZC00ZmNiLThhNzQtZmJjODEzNzQ4NDM4IiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJhd3MuY29nbml0by5zaWduaW4udXNlci5hZG1pbiIsImF1dGhfdGltZSI6MTc0NDU2NjIwOSwiZXhwIjoxNzQ0NTY5ODA5LCJpYXQiOjE3NDQ1NjYyMDksImp0aSI6IjJkMDg4YTI5LWQyMjUtNGY2MC1hMDliLTMwZmYwYzRjMWIzOSIsInVzZXJuYW1lIjoicHJhandhbHNAdmVyaXR5bGFicy5haSJ9.NmtNZFJcZ-VFYGMYu2vWfdMNxll2bm_5_6Hskg8pIkVNp6KwJ8rH6dgVUmVE0cTIpTCPUASgcSJKHjAEWW0b0qEAk0zNvWduh8kQfuR3TCTIEuOnCkIK9MgSZsfUQRDZ-8QskZjVmX3apmdSXPobQK7uQQhU1Za5_QJ6vh-mMEaKL5UIfLLEw8iaKf5SapAvtvIIqCVCdZfyLPCKf8N4YaAdq_If4kNoJcNHyJ6WZz3OEgwqz_elcCBV7GDx_fNmBfAYAulqQcgLZJEs473o6CE87014Xf89kaXtVAUFHsd0QxB6ZweRykFhbLdbmUX7KaOD7CY0eABeLH4JtE5q2A" \
  -d '{ 
  "messages": [
    {
      "role": "user",
      "content": "ovarian cancer"
    }
  ],

  "index_name": "120569609191-growth-unstructured",
  "organisation": "tellusdemo",
  "knowledge_base": "all",
  "processing_strategy": "unstructured"
}';

##### API KEY  
  curl -X POST https://api.tellussol.ai/api/chat/completions \
  -H "Content-Type: application/json" \
  -H "x-api-key: <<API KEY>> \
  -d "{    "messages": [
      {
        "role": "user",
        "content": "ovarian cancer"
      },
      "index_name": "test"
    ]}"


curl -X GET https://s81av56ha5.execute-api.us-east-1.amazonaws.com/dev/api/models \
  -H "Content-Type: application/json" \
  -H "x-api-key: <<api-key>>" 

curl -X GET https://s81av56ha5.execute-api.us-east-1.amazonaws.com/dev/api/models -H "Content-Type: application/json" -H "x-api-key: <<api-key>>"  
curl -X GET https://api.tellussol.ai/api/models -H "Content-Type: application/json" -H "x-api-key: <<api-key>>"  


### oauth login
https://tellus-user-pool-dev-domain.auth.us-east-1.amazoncognito.com/login
    ?client_id=5fi34f3tnkg3jfs7qjmeg74u0c
    &response_type=code
    &scope=openid+profile+email
    &redirect_uri=https://veritylabs.ai/auth/callback


### aws cloudfront
curl https://d2fypihoq3hoqw.cloudfront.net/models
curl -k https://chat.veritylabs.ai/models

curl https://q97ts95r6i.execute-api.us-east-1.amazonaws.com/models
curl -k https://app-alb-1876574907.us-east-1.elb.amazonaws.com/services/rag-generation/models
curl https://chat.veritylabs.ai/services/rag-generation/models
curl https://api.veritylabs.ai/models
curl https://d-krko8rx8de.execute-api.us-east-1.amazonaws.com/models

curl -N -X POST https://cdn.veritylabs.ai/chat/completions \
  -H "Authorization: Bearer eyJraWQiOiJ2U3IyTEJselIwZno5UmdwcUNZVCtWSjhqYjNhM1VacXBPcWgreGRNVVFNPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiIwNDY4ZTQwOC1hMDExLTcwYTQtZmFkNi1mODI1ZjA0YThlOTEiLCJjb2duaXRvOmdyb3VwcyI6WyJmcmVlLXVzZXJzIl0sImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX2xQcEZCQVRmQiIsImNsaWVudF9pZCI6IjVmaTM0ZjN0bmtnM2pmczdxam1lZzc0dTBjIiwib3JpZ2luX2p0aSI6IjY4ZmJiN2YyLTFjNzktNGU5MS05YTA4LTRiMTFmNTJiMjE4MSIsImV2ZW50X2lkIjoiZTAzMDljMDQtZjQ4Ny00YzNkLWFlMzAtOTIxODY3ZDllNDBmIiwidG9rZW5fdXNlIjoiYWNjZXNzIiwic2NvcGUiOiJhd3MuY29nbml0by5zaWduaW4udXNlci5hZG1pbiIsImF1dGhfdGltZSI6MTc0NDA1Mzc5MywiZXhwIjoxNzQ0MDU3MzkzLCJpYXQiOjE3NDQwNTM3OTMsImp0aSI6IjM2M2U2NWUxLTAyMDgtNDFhMi1iNTc1LWJkNGRhMWZlNzYyYyIsInVzZXJuYW1lIjoicHJhandhbHNAdmVyaXR5bGFicy5haSJ9.GVTGDFjfg0SepFT_yTfRHiEefq3CTQKZXyNqDOLUfgUG6894VktaogKFskNIRqQ7mhC8npAg3pk2zQ5GlaIbSj4hgnYrPPu-b7TOWo6JW-uvYjigus6wsS4IjNFsAr8w9o4zUJ6HXs_TVCE9OIg4geMrwsjPqEyO5MJ4cH9SmnB_9-u_4P3vHQhZ6RqxcnOa5X1hRZXAZ27FCgbmcdYPcbvWz98RAxQyJliYSflLXt2-wh2rrkT_PHA3qlO6jwf3j3l0QGlA8LBpIK2s_j-T1204y0xJaIRzPL7-GhqK0c-riyCEiS6zVyMB9uXcQyA-i9y0_J1B4efcgZYDqSIWNw" \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "ovarian cancer"}], "stream": "True"}'


https://api.veritylabs.ai/services/rag-generation/models    



curl -k -X 'POST' \
  'https://chat.veritylabs.ai/services/rag-generation/chat/completions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_COGNITO_JWT_TOKEN' \
  -d '{
  "messages": [
    {
      "role": "user",
      "content": "ovarian cancer"
    }
  ],
  "index_name": "120569609191-growth-unstructured",
  "organisation": "tellusdemo",
  "knowledge_base": "all",
  "processing_strategy": "unstructured"
}'