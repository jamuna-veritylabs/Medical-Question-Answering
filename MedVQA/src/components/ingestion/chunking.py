# src/components/ingestion/chunking.py

from langchain.text_splitter import RecursiveCharacterTextSplitter
from typing import List


def chunk_text(
    text: str,
    chunk_size: int = 500,
    overlap: int = 50
) -> List[str]:
    """
    Split text into semantic chunks using a recursive character splitter.

    Args:
        text (str): The full text to be split.
        chunk_size (int): Max number of characters per chunk.
        overlap (int): Number of characters to overlap between chunks.

    Returns:
        List[str]: A list of text chunks.
    """
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=overlap,
        separators=["\n\n", "\n", ".", " ", ""]
    )
    chunks = splitter.split_text(text)
    return chunks
