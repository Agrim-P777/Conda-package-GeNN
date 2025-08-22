#!/bin/bash
set -euo pipefail

# Resolve PREFIX robustly:
# 1) Use conda-provided $PREFIX if present (during conda install)
# 2) Fallback to the env dir inferred from this script's location: $ENV/bin/.pkg-post-link.sh
if [[ -z "${PREFIX:-}" ]]; then
  # Script is installed as $ENV/bin/.pygenn-cuda-post-link.sh
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PREFIX="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi

MSG_FILE="${PREFIX}/.messages.txt"

cat > "${MSG_FILE}" <<'EOF'

============================================
PyGeNN CUDA backend installed successfully!

To enable CUDA support, set the environment variable:
    export CUDA_PATH=$CONDA_PREFIX

Alternatively, if you have a system-wide CUDA installation:
    export CUDA_PATH=/usr/local/cuda-12.x

PyGeNN will automatically use CUDA_PATH if set; otherwise, you may
need to manually configure it for certain use cases.
============================================

EOF

# Also echo to stderr so it appears during 'Executing transaction:'
cat "${MSG_FILE}" 1>&2
