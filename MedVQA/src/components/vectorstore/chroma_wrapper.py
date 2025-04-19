# src/components/vectorstore/chroma_wrapper.py

import chromadb
from chromadb.utils import embedding_functions
from typing import List


class ChromaVectorStore:
    def __init__(self, collection_name: str = "default"):
        self.client = chromadb.Client()
        self.collection = self.client.get_or_create_collection(name=collection_name)

    def add_texts(self, texts: List[str], embeddings: List[List[float]]):
        for i, (text, emb) in enumerate(zip(texts, embeddings)):
            self.collection.add(
                documents=[text],
                ids=[f"chunk_{i}"],
                embeddings=[emb]
            )

    def similarity_search(self, query: str, query_embedding: List[float], k: int = 5) -> List[str]:
        result = self.collection.query(query_embeddings=[query_embedding], n_results=k)
        return result["documents"][0]  # List of top-k documents
