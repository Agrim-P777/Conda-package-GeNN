#!/usr/bin/env bash
set -ex

# CPU-only build
unset CUDA_PATH

# macOS toolchain flags
if [[ "$target_platform" == osx-* ]]; then
  export LTO_LIBRARY="$BUILD_PREFIX/lib/libLTO.dylib"
  export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
  export CFLAGS="$CFLAGS -I$PREFIX/include"
  export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -lffi"
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Run extra macOS dylib fixups
if [[ "$target_platform" == osx-* ]]; then
  bash "${RECIPE_DIR}/macos_helper.sh"
fi
