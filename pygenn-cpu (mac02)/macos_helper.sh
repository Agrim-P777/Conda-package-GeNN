#!/usr/bin/env bash
set -ex

echo "Running macOS dylib fixups..."
SP_DIR=$($PYTHON -c "import site; print(site.getsitepackages()[0])")

for d in "$SRC_DIR/pygenn" "$SRC_DIR/src/genn/genn"; do
  if [[ -f "$d/libgenn_dynamic.dylib" ]]; then
    cp -v "$d/libgenn_dynamic.dylib" "$SP_DIR/pygenn/"
  fi
  if [[ -f "$d/libgenn_single_threaded_cpu_backend_dynamic.dylib" ]]; then
    cp -v "$d/libgenn_single_threaded_cpu_backend_dynamic.dylib" "$SP_DIR/pygenn/"
  fi
done

if [[ ! -f "$SP_DIR/pygenn/libgenn_dynamic.dylib" ]]; then
  echo "ERROR: libgenn_dynamic.dylib not found" >&2
  exit 1
fi

install_name_tool -id "@loader_path/libgenn_dynamic.dylib" \
  "$SP_DIR/pygenn/libgenn_dynamic.dylib" || true

if [[ -f "$SP_DIR/pygenn/libgenn_single_threaded_cpu_backend_dynamic.dylib" ]]; then
  install_name_tool -id "@loader_path/libgenn_single_threaded_cpu_backend_dynamic.dylib" \
    "$SP_DIR/pygenn/libgenn_single_threaded_cpu_backend_dynamic.dylib" || true
fi

for so in "$SP_DIR/pygenn/"*.so; do
  install_name_tool -change "@loader_path/libgenn_dynamic.dylib" \
    "@loader_path/libgenn_dynamic.dylib" "$so" || true
  install_name_tool -change "@loader_path/libgenn_single_threaded_cpu_backend_dynamic.dylib" \
    "@loader_path/libgenn_single_threaded_cpu_backend_dynamic.dylib" "$so" || true
  install_name_tool -add_rpath "@loader_path" "$so" || true
done
