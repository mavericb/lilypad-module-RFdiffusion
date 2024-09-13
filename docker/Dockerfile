# Use NVIDIA CUDA base image
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install git and other dependencies
RUN apt-get -q update \
    && apt-get install --no-install-recommends -y \
    git \
    python3.9 \
    python3-pip \
    wget \
    && python3.9 -m pip install -q -U --no-cache-dir pip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

# Clone the repository
RUN git clone https://github.com/RosettaCommons/RFdiffusion.git /app/RFdiffusion

# Set working directory to the cloned repository
WORKDIR /app/RFdiffusion

# Install Python packages
RUN pip install -q --no-cache-dir \
    dgl==1.0.2+cu116 -f https://data.dgl.ai/wheels/cu116/repo.html \
    torch==1.12.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116 \
    e3nn==0.3.3 \
    wandb==0.12.0 \
    pynvml==11.0.0 \
    git+https://github.com/NVIDIA/dllogger#egg=dllogger \
    decorator==5.1.0 \
    hydra-core==1.3.2 \
    pyrsistent==0.19.3 \
    /app/RFdiffusion/env/SE3Transformer \
    && pip install --no-cache-dir /app/RFdiffusion --no-deps

# Set environment variable
ENV DGLBACKEND="pytorch"

# Download models
RUN mkdir -p /app/models && \
    wget -P /app/models \
    http://files.ipd.uw.edu/pub/RFdiffusion/6f5902ac237024bdd0c176cb93063dc4/Base_ckpt.pt \
    http://files.ipd.uw.edu/pub/RFdiffusion/e29311f6f1bf1af907f9ef9f44b8328b/Complex_base_ckpt.pt \
    http://files.ipd.uw.edu/pub/RFdiffusion/60f09a193fb5e5ccdc4980417708dbab/Complex_Fold_base_ckpt.pt \
    http://files.ipd.uw.edu/pub/RFdiffusion/74f51cfb8b440f50d70878e05361d8f0/InpaintSeq_ckpt.pt \
    http://files.ipd.uw.edu/pub/RFdiffusion/76d00716416567174cdb7ca96e208296/InpaintSeq_Fold_ckpt.pt \
    http://files.ipd.uw.edu/pub/RFdiffusion/5532d2e1f3a4738decd58b19d633b3c3/ActiveSite_ckpt.pt \
    http://files.ipd.uw.edu/pub/RFdiffusion/12fc204edeae5b57713c5ad7dcb97d39/Base_epoch8_ckpt.pt

# Copy additional files
COPY Dockerfile /app/Dockerfile
COPY main.py /app/main.py
COPY start.sh /app/start.sh

# Make start.sh executable
RUN chmod +x /app/start.sh

# Set the entrypoint
ENTRYPOINT ["/app/start.sh"]

# Usage Instructions:
# 1. Ensure Dockerfile, main.py, requirements.txt, and start.sh are in the same directory
# 2. Build the Docker image:
#    docker build -t yourusername/rfdiffusion:cuda-offline .
# 3. Push to Docker Hub:
#    docker push yourusername/rfdiffusion:cuda-offline
# 4. On the target machine with CUDA support, pull the image:
#    docker pull yourusername/rfdiffusion:cuda-offline
# 5. Run offline:
#    docker run -it --rm --gpus all --network none \
#      -v $HOME/inputs:/app/inputs \
#      -v $HOME/outputs:/app/outputs \
#      yourusername/rfdiffusion:cuda-offline \
#      inference.output_prefix=/app/outputs/motifscaffolding \
#      inference.model_directory_path=/app/models \
#      inference.input_pdb=/app/inputs/5TPN.pdb \
#      inference.num_designs=3 \
#      'contigmap.contigs=[10-40/A163-181/10-40]'