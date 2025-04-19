# src/components/rag/qa_workflow.py

from ingestion.pdf_ingestion import extract_text_from_pdf_s3
from ingestion.chunking import chunk_text


def run_rag_qa_workflow(bucket: str, key: str, query: str, embedder, vectorstore, llm, chunk_size=500, overlap=50):
    """
    End-to-end QA workflow using RAG pipeline.

    Args:
        bucket: S3 bucket
        key: S3 key to the PDF
        query: Question to answer
        embedder: Embedder class instance
        vectorstore: Vector store instance
        llm: LLM instance
        chunk_size: Chunking param
        overlap: Chunking param

    Returns:
        str: Final generated answer
    """
    text = extract_text_from_pdf_s3(bucket, key)
    chunks = chunk_text(text, chunk_size=chunk_size, overlap=overlap)

    from rag.pipeline import RAGPipeline
    rag = RAGPipeline(embedder=embedder, vectorstore=vectorstore, llm=llm)

    return rag.run(texts=chunks, query=query)
