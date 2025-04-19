# setup.py

from setuptools import setup, find_packages

setup(
    name="ai-acc-stack",
    version="0.1.0",
    description="Modular RAG framework for AI workflows",
    author="Jamuna S Murthy",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    install_requires=open("requirements.txt").read().splitlines(),
    include_package_data=True,
)

