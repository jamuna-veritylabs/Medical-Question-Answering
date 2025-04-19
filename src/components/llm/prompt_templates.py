# src/components/llm/prompt_templates.py

def qa_prompt_template(context: str, question: str) -> str:
    """
    Standard QA prompt template.

    Args:
        context (str): Retrieved chunks from vector DB
        question (str): User query

    Returns:
        str: Prompt for the LLM
    """
    return f"""Human: Use the context below to answer the question.

Context:
{context}

Question:
{question}

Assistant:"""
