# src/components/vectorstore/faiss_store.py

import faiss
import numpy as np
from typing import List


class FAISSVectorStore:
    def __init__(self, dim: int):
        self.dim = dim
        self.index = faiss.IndexFlatL2(dim)
        self.texts = []  # Store text separately

    def add_texts(self, texts: List[str], embeddings: List[List[float]]):
        vectors = np.array(embeddings).astype("float32")
        self.index.add(vectors)
        self.texts.extend(texts)

    def similarity_search(self, query_embedding: List[float], k: int = 5) -> List[str]:
        query = np.array([query_embedding]).astype("float32")
        D, I = self.index.search(query, k)
        return [self.texts[i] for i in I[0] if i < len(self.texts)]
