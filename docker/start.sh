#!/bin/bash

echo "RFdiffusion container started"

# Setup SSH if public key is provided
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

# Activate the virtual environment
source /app/venv/bin/activate

# Print some information about the environment
echo "Python version:"
python --version
echo "CUDA version:"
nvcc --version
echo "PyTorch version:"
python -c "import torch; print(torch.__version__)"
echo "CUDA available:"
python -c "import torch; print(torch.cuda.is_available())"

# Check if necessary directories exist
if [ ! -d "/app/venv/lib/python3.10/site-packages/models" ]; then
    echo "Error: models directory not found!"
    exit 1
fi

if [ ! -d "/app/venv/lib/python3.10/site-packages/examples" ]; then
    echo "Error: examples directory not found!"
    exit 1
fi

if [ ! -d "/app/outputs" ]; then
    echo "Error: outputs directory not found!"
    mkdir -p /app/outputs
fi

# Set default values for environment variables if they are not set
: ${OUTPUT_PREFIX:="/app/outputs/default_output"}
: ${MODEL_DIRECTORY:="/app/venv/lib/python3.10/site-packages/models"}
: ${INPUT_PDB:="/app/venv/lib/python3.10/site-packages/examples/input_pdbs/1qys.pdb"}
: ${NUM_DESIGNS:="3"}
: ${CONTIGS:="A1-10/20-30/40-50"}

# Print the values being used
echo "Using the following parameters:"
echo "OUTPUT_PREFIX: $OUTPUT_PREFIX"
echo "MODEL_DIRECTORY: $MODEL_DIRECTORY"
echo "INPUT_PDB: $INPUT_PDB"
echo "NUM_DESIGNS: $NUM_DESIGNS"
echo "CONTIGS: $CONTIGS"

# Prepare the command
CMD="python /app/RFdiffusion/scripts/run_inference.py"

# Add environment variables to the command
CMD="$CMD inference.output_prefix=$OUTPUT_PREFIX"
CMD="$CMD inference.model_directory_path=$MODEL_DIRECTORY"
CMD="$CMD inference.input_pdb=$INPUT_PDB"
CMD="$CMD inference.num_designs=$NUM_DESIGNS"
CMD="$CMD contigmap.contigs=[$CONTIGS]"

# Check if we have command line arguments
if [ $# -eq 0 ]; then
    echo "No additional arguments provided. Running with environment variables..."
    eval $CMD
else
    echo "Running with provided arguments..."
    eval $CMD "$@"
fi

# Add any cleanup or final tasks here
echo "RFdiffusion task completed."