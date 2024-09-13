#!/bin/bash

echo "pod2 started"

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

set -e

# Print some information about the environment
echo "Starting RFdiffusion container..."
echo "Python version:"
python3 --version
echo "CUDA version:"
nvcc --version
echo "PyTorch version:"
python3 -c "import torch; print(torch.__version__)"
echo "CUDA available:"
python3 -c "import torch; print(torch.cuda.is_available())"

# Check if we have command line arguments
if [ $# -eq 0 ]; then
    echo "No arguments provided. Running default inference script..."
    python3 scripts/run_inference.py
else
    echo "Running with provided arguments..."
    python3 scripts/run_inference.py "$@"
fi

# You can add any other initialization or check here
# For example, checking if necessary files exist:
if [ ! -d "/app/models" ]; then
    echo "Error: models directory not found!"
    exit 1
fi

# Add any cleanup or final tasks here
echo "RFdiffusion task completed."