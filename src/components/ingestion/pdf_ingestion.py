# src/components/ingestion/pdf_ingestion.py

import boto3
import io
from PyPDF2 import PdfReader


def extract_text_from_pdf_bytes(pdf_bytes: bytes) -> str:
    """
    Extract text from PDF file bytes using PyPDF2.

    Args:
        pdf_bytes (bytes): PDF content as bytes

    Returns:
        str: Extracted text from all PDF pages
    """
    reader = PdfReader(io.BytesIO(pdf_bytes))
    text = "\n".join([page.extract_text() or "" for page in reader.pages])
    return text


def extract_text_from_pdf_local(file_path: str) -> str:
    """
    Extract text from a local PDF file.

    Args:
        file_path (str): Path to the local PDF file

    Returns:
        str: Extracted text from the PDF
    """
    with open(file_path, "rb") as f:
        return extract_text_from_pdf_bytes(f.read())


def extract_text_from_pdf_s3(bucket: str, key: str, region: str = "us-east-1") -> str:
    """
    Extract text from a PDF file stored in an S3 bucket.

    Args:
        bucket (str): S3 bucket name
        key (str): Key/path to the PDF file in S3
        region (str): AWS region

    Returns:
        str: Extracted text from the PDF
    """
    s3 = boto3.client("s3", region_name=region)
    obj = s3.get_object(Bucket=bucket, Key=key)
    pdf_bytes = obj["Body"].read()
    return extract_text_from_pdf_bytes(pdf_bytes)
