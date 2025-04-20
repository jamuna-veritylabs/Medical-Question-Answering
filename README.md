# 🌟 Benchmarking Framework 🌟

### 🗂️ Project Structure

Here’s how the repository is organized:
```bash
/benchmarking-framework
Medical-Question-Answering/
│
├── src/                                # Core backend components
│   └── components/
│       ├── ingestion/                  # PDF loading, text extraction, chunking
│       │   ├── pdf_ingestion.py
│       │   └── chunking.py
│       │
│       ├── embeddings/                 # Embedding models (SBERT, Titan, etc.)
│       │   ├── titan_embedder.py
│       │   └── sbert_embedder.py
│       │
│       ├── vectorstore/                # Vector DB wrappers (Chroma, FAISS, OpenSearch)
│       │   ├── chroma_wrapper.py
│       │   ├── faiss_store.py
│       │   └── opensearch_store.py
│       │
│       ├── llm/                        # LLM model integration (Bedrock, HF, etc.)
│       │   ├── bedrock_llm.py
│       │   └── prompt_templates.py
│       │
│       └── rag/                        # Full RAG pipelines / orchestration logic
│           ├── pipeline.py
│           └── qa_workflow.py
│
├── examples/                           # Jupyter notebooks and demo flows
│   ├── rag_demo.ipynb                  # Full end-to-end RAG notebook
│   ├── sbert_local_demo.ipynb         # Local SBERT + Chroma test
│   └── titan_bedrock_demo.ipynb       # Titan + Bedrock version
│
├── infra/                              # Terraform remote state config
│   └── remote-state/
│       ├── backend.tf
│       └── s3.tf
│
├── src/blueprints/                     # Terraform blueprints for RAG deployment
│   ├── bedrock_assistant.tf
│   ├── vector_db.tf
│   └── s3_ingestion.tf
│
├── scripts/                            # CLI tools and utilities
│   ├── docker/
│   │   ├── Dockerfile
│   │   └── entrypoint.sh
│   └── deploy.sh                       # One-command infra deployment
│
├── .env                                # Environment config (optional)
├── .gitignore
├── requirements.txt                    # Python dependencies
├── docker-compose.yml                  # Multi-service local dev setup
├── README.md
└── LICENSE
```

### 📜 License

This project is licensed under the MIT License. See the LICENSE file for more details.

### 📱 Contact

For any questions or suggestions, feel free to open an issue or contact me at jamuna@veritylabs.ai
