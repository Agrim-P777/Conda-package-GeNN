FROM --platform=linux/amd64 ubuntu:22.04

RUN apt-get update && apt-get install -y \
  wget \
  curl \
  bzip2 \
  ca-certificates \
  git \
  build-essential \
  cmake \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Install Miniforge
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && \
    bash Miniforge3-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniforge3-Linux-x86_64.sh

ENV PATH=/opt/conda/bin:$PATH

# Configure Conda
RUN conda init && \
    conda config --set ssl_verify true && \
    conda install -y certifi conda-build boa -c conda-forge

WORKDIR /recipe
