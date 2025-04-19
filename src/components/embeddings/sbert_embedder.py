# src/components/embeddings/sbert_embedder.py

from sentence_transformers import SentenceTransformer
from typing import List


class SBERTEmbedder:
    def __init__(self, model_name: str = "all-MiniLM-L6-v2"):
        self.model = SentenceTransformer(model_name)

    def embed_texts(self, texts: List[str]) -> List[List[float]]:
        """
        Generate embeddings for a list of text chunks.

        Args:
            texts (List[str]): Input texts

        Returns:
            List[List[float]]: Embeddings for each text
        """
        return self.model.encode(texts, convert_to_tensor=False)
