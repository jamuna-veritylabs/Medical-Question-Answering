# src/components/embeddings/titan_embedder.py

import boto3
import json
from typing import List


class TitanTextEmbedder:
    def __init__(self, model_id="amazon.titan-embed-text-v1", region="us-east-1"):
        self.model_id = model_id
        self.bedrock = boto3.client("bedrock-runtime", region_name=region)

    def embed_texts(self, texts: List[str]) -> List[List[float]]:
        """
        Generate embeddings from Titan model via AWS Bedrock.

        Args:
            texts (List[str]): Input text chunks

        Returns:
            List[List[float]]: Embedding vectors
        """
        embeddings = []
        for text in texts:
            body = json.dumps({
                "inputText": text
            })
            response = self.bedrock.invoke_model(
                modelId=self.model_id,
                body=body,
                contentType="application/json",
                accept="application/json"
            )
            result = json.loads(response["body"].read())
            embeddings.append(result["embedding"])
        return embeddings
