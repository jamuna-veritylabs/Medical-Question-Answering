# utils.py
import sys
import os

def add_project_root_to_sys_path():
    """
    Dynamically adds the project root directory to the system path.
    """
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__)))
    if project_root not in sys.path:
        sys.path.append(project_root)
