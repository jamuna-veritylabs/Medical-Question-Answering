# src/components/rag/pipeline.py

from typing import List
from llm.prompt_templates import qa_prompt_template


class RAGPipeline:
    def __init__(self, embedder, vectorstore, llm):
        """
        Args:
            embedder: Embedding model (SBERT, Titan, etc.)
            vectorstore: Vector store (Chroma, FAISS, OpenSearch)
            llm: Language model (BedrockLLM, etc.)
        """
        self.embedder = embedder
        self.vectorstore = vectorstore
        self.llm = llm

    def run(self, texts: List[str], query: str, embeddings: List[List[float]] = None, top_k: int = 5) -> str:
        """
        Perform end-to-end RAG: store → retrieve → generate

        Args:
            texts: Source chunks
            query: User question
            embeddings: Optional precomputed embeddings
            top_k: Number of chunks to retrieve

        Returns:
            Final answer string
        """
        if embeddings is None:
            embeddings = self.embedder.embed_texts(texts)

        self.vectorstore.add_texts(texts, embeddings)

        query_embedding = self.embedder.embed_texts([query])[0]
        top_chunks = self.vectorstore.similarity_search(query=query, query_embedding=query_embedding, k=top_k)

        prompt = qa_prompt_template(context=" ".join(top_chunks), question=query)
        return self.llm.generate(prompt)
