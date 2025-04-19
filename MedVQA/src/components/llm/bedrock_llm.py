# src/components/llm/bedrock_llm.py

import boto3
import json


class BedrockLLM:
    def __init__(self, model_id: str = "anthropic.claude-3-haiku-20240307", region: str = "us-east-1"):
        self.model_id = model_id
        self.client = boto3.client("bedrock-runtime", region_name=region)

    def generate(self, prompt: str, max_tokens: int = 500, temperature: float = 0.7) -> str:
        """
        Generate response from a Bedrock-hosted LLM.

        Args:
            prompt (str): Full prompt including context and question
            max_tokens (int): Max number of tokens in output
            temperature (float): Sampling temperature

        Returns:
            str: Model-generated response
        """
        body = {
            "prompt": prompt,
            "max_tokens_to_sample": max_tokens,
            "temperature": temperature,
            "stop_sequences": ["\n\nHuman:"]
        }

        response = self.client.invoke_model(
            modelId=self.model_id,
            body=json.dumps(body),
            contentType="application/json",
            accept="application/json"
        )

        result = json.loads(response["body"].read())
        return result.get("completion", result)  # Claude returns `completion`
