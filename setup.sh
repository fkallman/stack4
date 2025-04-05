#!/bin/bash

# Load VS Code editor
module load prog/vscode/1.85.2

# Load open source tools, specifically Icarus and GHDL
module load prog/oss-cad-suite/2025.03.10

# Load Python
module load prog/anaconda3/2024.02.1

# The Python installation from anaconda conflicts with oss-cad-suite, this fixes that
export PYTHONPATH=/home/$USERNAME/.local/lib/python3.11/site-packages/

# Install cocotb for running the testbench
python -m pip install cocotb