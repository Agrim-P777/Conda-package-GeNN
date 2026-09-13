#!/usr/bin/env bash
set -ex

# Only for macOS builds
if [[ "${target_platform:-}" != osx-* ]]; then
  exit 0
fi

echo "macOS: ensuring local @loader_path deps for GeNN runtime libs"

# Conda build sets SP_DIR; fall back if needed
if [[ -z "${SP_DIR:-}" ]]; then
  SP_DIR="$($PYTHON -c 'import site; print([p for p in site.getsitepackages() if "site-packages" in p][-1])')"
fi

PKG_DIR="$SP_DIR/pygenn"

# Where the build may have left runtime dylibs
CANDIDATES=(
  "$SRC_DIR/pygenn"                 # setup.py's LIBRARY_DIRECTORY
  "$SRC_DIR/src/genn/genn"          # fallback if make dropped here
)

mkdir -p "$PKG_DIR"

# Copy in runtime dylibs (any *_dynamic*.dylib variant) if missing
copy_if_missing () {
  local name_glob="$1"              # e.g. libgenn*_dynamic*.dylib
  local dest_basename="$2"          # e.g. libgenn_dynamic.dylib
  # If the canonical file already exists, skip
  if [[ -f "$PKG_DIR/$dest_basename" ]]; then
    return 0
  fi
  for src in "${CANDIDATES[@]}"; do
    # Pick the first matching variant we can find
    local cand
    cand=$(ls "$src"/$name_glob 2>/dev/null | head -n 1 || true)
    if [[ -n "$cand" ]]; then
      echo "Copying $(basename "$cand") -> $dest_basename"
      cp -v "$cand" "$PKG_DIR/$dest_basename"
      return 0
    fi
  done
}

# Ensure both core and backend runtime dylibs are present (canonical names)
copy_if_missing "libgenn*_dynamic*.dylib" "libgenn_dynamic.dylib"
copy_if_missing "libgenn_single_threaded_cpu_backend*_dynamic*.dylib" "libgenn_single_threaded_cpu_backend_dynamic.dylib"

# Hard fail if the core lib is still missing
[[ -f "$PKG_DIR/libgenn_dynamic.dylib" ]] || { echo "ERROR: libgenn_dynamic.dylib not found in $PKG_DIR"; exit 1; }

# Give each runtime dylib a local install_name id and make sure @loader_path is searched
for dylib in "$PKG_DIR"/libgenn*_dynamic*.dylib; do
  [[ -f "$dylib" ]] || continue
  base=$(basename "$dylib")
  install_name_tool -id "@loader_path/${base}" "$dylib" || true
  install_name_tool -add_rpath "@loader_path" "$dylib" || true
done

# Normalize libc++ on the runtime dylibs to match conda's libcxx
# (many .so already use @rpath/libc++.1.dylib; the dylibs sometimes use /usr/lib)
for dylib in "$PKG_DIR"/libgenn*_dynamic*.dylib; do
  [[ -f "$dylib" ]] || continue
  if otool -L "$dylib" | grep -q "/usr/lib/libc++.1.dylib"; then
    install_name_tool -change /usr/lib/libc++.1.dylib @rpath/libc++.1.dylib "$dylib" || true
  fi
done

# Helper to rewrite a dependency reference in a consumer binary to our local @loader_path ids
rewrite_dep () {
  local file="$1"
  local dep_basename="$2"   # e.g. libgenn_dynamic.dylib
  # Absolute or relative references to this dep -> @loader_path/dep_basename
  if otool -L "$file" | grep -q "$dep_basename"; then
    install_name_tool -change "$dep_basename" "@loader_path/$dep_basename" "$file" || true
  fi
  if otool -L "$file" | grep -q "@rpath/$dep_basename"; then
    install_name_tool -change "@rpath/$dep_basename" "@loader_path/$dep_basename" "$file" || true
  fi
  # Some build layouts embed a full path to site-packages
  local full="$PKG_DIR/$dep_basename"
  if otool -L "$file" | grep -q "$full"; then
    install_name_tool -change "$full" "@loader_path/$dep_basename" "$file" || true
  fi
}

# For every pygenn extension + our dylibs:
# - ensure @loader_path is searched
# - rewrite any references to point at our local @loader_path ids
for f in "$PKG_DIR"/*.so "$PKG_DIR"/libgenn*_dynamic*.dylib; do
  [[ -f "$f" ]] || continue
  install_name_tool -add_rpath "@loader_path" "$f" || true

  rewrite_dep "$f" "libgenn_dynamic.dylib"
  rewrite_dep "$f" "libgenn_single_threaded_cpu_backend_dynamic.dylib"

  # If any consumer itself still references /usr/lib/libc++.1.dylib, normalize it too
  if otool -L "$f" | grep -q "/usr/lib/libc++.1.dylib"; then
    install_name_tool -change /usr/lib/libc++.1.dylib @rpath/libc++.1.dylib "$f" || true
  fi
done

echo "Done."
