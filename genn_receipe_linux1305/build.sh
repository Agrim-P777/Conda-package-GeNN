#!/bin/bash
set -ex

# Ensure compilers are set correctly by Conda
export CC=${CC}
export CXX=${CXX}

# Create and move into the build directory
mkdir -p build
cd build

# Run CMake with explicit compiler definitions and CUDA settings
cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc \
  -DCMAKE_BUILD_TYPE=Release \
  -DGE_NN_BUILD_EXAMPLES=OFF \
  -DGE_NN_BUILD_TESTS=OFF

# Build and install
make -j$(nproc)
make install VERBOSE=1
