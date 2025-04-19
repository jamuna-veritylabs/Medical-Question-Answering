# src/components/vectorstore/opensearch_store.py

from opensearchpy import OpenSearch, RequestsHttpConnection
from typing import List
import numpy as np
import uuid
import boto3
import json


class OpenSearchKNN:
    def __init__(self, host: str, index_name: str, dim: int):
        self.index_name = index_name
        self.client = OpenSearch(
            hosts=[{"host": host, "port": 443}],
            http_auth=None,  # Use IAM for auth or SigV4 if needed
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection
        )

        if not self.client.indices.exists(index_name):
            self._create_index(dim)

    def _create_index(self, dim):
        index_body = {
            "settings": {
                "index": {
                    "knn": True
                }
            },
            "mappings": {
                "properties": {
                    "text": {"type": "text"},
                    "vector": {
                        "type": "knn_vector",
                        "dimension": dim
                    }
                }
            }
        }
        self.client.indices.create(index=self.index_name, body=index_body)

    def add_texts(self, texts: List[str], embeddings: List[List[float]]):
        for text, vector in zip(texts, embeddings):
            doc = {
                "text": text,
                "vector": vector
            }
            self.client.index(index=self.index_name, body=doc, id=str(uuid.uuid4()))

    def search(self, query_vector: List[float], k=5) -> List[str]:
        query = {
            "size": k,
            "query": {
                "knn": {
                    "vector": {
                        "vector": query_vector,
                        "k": k
                    }
                }
            }
        }
        response = self.client.search(index=self.index_name, body=query)
        return [hit["_source"]["text"] for hit in response["hits"]["hits"]]
