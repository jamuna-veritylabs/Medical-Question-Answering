# 🌟 LLM Benchmarking Framework 🌟

## 📜 Overview

Welcome to the **LLM Benchmarking Framework**! This project provides a powerful tool for benchmarking **Language Models (LLMs)** across various evaluation metrics including **accuracy**, **hallucination detection**, and **helpfulness evaluation**. Our framework leverages state-of-the-art models like **T5**, **GPT-3/4**, **RoBERTa**, and **BERT**, alongside external fact-checking tools such as **ClaimBuster** to assess the **factual correctness**, **completeness**, and **reliability** of model responses. 🤖

### 🛠️ Key Features
- **📝 Question Generation**: Automatically generate simple and complex questions from a given prompt using **GPT-3/4** or **T5**.
- **🔍 Ground Truth Extraction**: Extract correct answers using **RoBERTa** from reference documents.
- **🔍 Hallucination Detection**: Detect hallucinations in responses with **RoBERTa-based fact-checking** or **ClaimBuster**.
- **💬 Helpfulness Evaluation**: Evaluate the helpfulness of responses based on their completeness and relevance using **T5** or **BERT**.

---

## ⚙️ Installation

To get started with the framework, follow the steps below to set it up on your local machine:

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/jamuna-veritylabs/benchmarking-framework.git
cd benchmarking-framework
```
2️⃣ Install Dependencies
Make sure you have Python 3.7+ installed. Then, install the required libraries with pip:
```bash
pip install -r requirements.txt
```
3️⃣ Download Pre-trained Models
Download the necessary pre-trained models for question generation, fact-checking, and helpfulness evaluation:

# Download T5, GPT-3, RoBERTa models
python scripts/download_models.py

### 🚀 Usage

Here’s how to use the framework for generating questions, extracting answers, detecting hallucinations, and evaluating helpfulness:

1️⃣ Generate Benchmark Questions
To generate a suite of questions related to a given prompt, run:
python scripts/generate_questions.py --prompt "climate change"

2️⃣ Extract Ground Truth
To extract the correct answer for a given question from a context:
python scripts/extract_answer.py --context "Paris is the capital of France." --question "What is the capital of France?"

3️⃣ Detect Hallucinations
To check the factual accuracy of a claim:
python scripts/fact_check.py --claim "Global warming causes faster crop growth." --context "Scientific research has shown that global warming has harmful effects on agriculture, such as drought and flooding."

4️⃣ Evaluate Helpfulness
To evaluate the helpfulness of a model's response based on an expected answer:
python scripts/evaluate_helpfulness.py --response "Global warming causes unpredictable weather patterns." --expected_answer "Global warming disrupts crop growth patterns and leads to unpredictable weather."

5️⃣ Run Full Benchmark Pipeline
To run the entire benchmarking pipeline across all tasks, simply execute:
python scripts/benchmark_pipeline.py
This will evaluate the models and generate performance reports, including:

Honesty: True/False (with hallucination level)
Helpfulness: Full, Partial, or Missing answers

### 🗂️ Project Structure

Here’s how the repository is organized:
```bash
/benchmarking-framework
│
├── /data                # Store datasets, benchmarks, and raw inputs
│   ├── /questions       # Benchmark questions (simple, complex, multimodal)
│   ├── /ground_truth    # Ground truth answers for benchmarking
│   └── /outputs         # Model output results from testing
│
├── /models              # Pre-trained and fine-tuned models
│   ├── /question-gen    # T5/GPT for question generation
│   ├── /answer-extraction  # RoBERTa for answer extraction
│   ├── /fact-checking   # RoBERTa-based or ClaimBuster for hallucination detection
│   └── /helpfulness     # T5/BERT for helpfulness evaluation
│
├── /notebooks           # Jupyter notebooks for experiments, benchmarks
│
├── /scripts             # Python scripts for core functionality
│   ├── generate_questions.py   # Script for generating questions using GPT/T5
│   ├── extract_answer.py       # Script for answer extraction with RoBERTa
│   ├── fact_check.py           # Script for hallucination detection (RoBERTa or ClaimBuster)
│   ├── evaluate_helpfulness.py # Script for evaluating helpfulness
│   └── benchmark_pipeline.py   # The main pipeline to run the benchmarking
│
├── requirements.txt     # Python dependencies for the project
└── README.md            # Project documentation
```
### ⚡ Models and Algorithms Used

This project integrates the following models and algorithms:

T5 and GPT-3/4 for question generation.
RoBERTa for answer extraction and hallucination detection.
ClaimBuster for fact-checking and hallucination detection.
BERT for helpfulness evaluation.
These models are fine-tuned on relevant datasets such as SQuAD, FEVER, and ClaimBuster to ensure robust performance on factual correctness, helpfulness, and hallucination detection.

### 🤝 Contributing

We welcome contributions to this project! Feel free to submit issues, suggest features, or open pull requests to improve the framework.

How to contribute:
Fork the repository 🍴.
Clone your forked repo to your local machine 💻.
Make changes or additions to the code ✨.
Create a pull request to submit your changes.

### 📜 License

This project is licensed under the MIT License. See the LICENSE file for more details.

### Acknowledgments

T5, GPT-3/4, RoBERTa, BERT for their state-of-the-art capabilities.
ClaimBuster for providing fact-checking tools.
Special thanks to the authors of the FEVER and SQuAD datasets.

### 📱 Contact

For any questions or suggestions, feel free to open an issue or contact me at jamuna@veritylabs.ai
