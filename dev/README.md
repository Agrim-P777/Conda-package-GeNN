# Development Recipes — Working Notes

This folder contains every intermediate recipe developed during the GSoC packaging work.
Each phase folder is a snapshot of the recipe at a specific stage of the process.
The **source of truth** is `../Conda_Forge/pygenn-suite/`, which is the recipe submitted to Conda-Forge.

---

## Phase Overview

| Folder | What it tried | Why it was superseded |
|--------|--------------|----------------------|
| [`phase-1_linux-cuda11.7`](phase-1_linux-cuda11.7/) | First CUDA recipe — Linux-only, monolithic `cudatoolkit 11.7` package | CUDA 11.7 uses a single `cudatoolkit` package that Conda-Forge was moving away from; needed to migrate to modular packages |
| [`phase-2_linux-cpu`](phase-2_linux-cpu/) | First CPU recipe — Linux-only (`skip: true # [not linux]`) | Needed to support Windows and macOS too |
| [`phase-3_linux-cuda12.4`](phase-3_linux-cuda12.4/) | Migrated to modular CUDA (`cuda-nvcc`, `cuda-cudart-dev`, etc.), pinned to 12.4 | Hard-pinning to 12.4 means users can't install with a different 12.x CUDA toolkit |
| [`phase-4_linux-cuda12.x`](phase-4_linux-cuda12.x/) | Added `cuda-version =={{ cuda_version }}` to float across any CUDA 12.x | Linux-only; still needed Windows support |
| [`phase-5a_windows-cpu`](phase-5a_windows-cpu/) | Explicit Windows CPU recipe exploring cross-platform `if win` build blocks | Intermediate exploration; consolidated into phase-5b |
| [`phase-5b_cross-platform-cpu`](phase-5b_cross-platform-cpu/) | Cross-platform CPU: Linux, macOS, Windows in one recipe | macOS runtime fails: `.dylib` files not copied to `site-packages`; also used plain `numpy` dependency without ABI pinning |
| [`phase-5c_winlinux-cpu`](phase-5c_winlinux-cpu/) | Refined cross-platform CPU: switched to `pin_compatible('numpy')` for proper ABI pinning, named final maintainers; tested on Windows + Linux | Still no macOS `.dylib` handling; macOS builds would fail at runtime |
| [`phase-6a_windows-cuda-msbuild`](phase-6a_windows-cuda-msbuild/) | Windows CUDA recipe using `CudaLibraryPath` env var (MSBuild-only) | MSBuild alone can't do *runtime* code compilation of user models; `CudaLibraryPath` was later renamed `CUDA_LIBRARY_PATH` in PR #705 |
| [`phase-6b_windows-cuda-nmake`](phase-6b_windows-cuda-nmake/) | Windows CUDA with NMake + MSBuild hybrid — resolves the runtime compile issue; uses a local source path for testing | Uses `path: F:/Windows/...` so it can't be used on other machines; needs a published tarball source |
| [`phase-7a_macos-cpu-inline`](phase-7a_macos-cpu-inline/) | macOS `.dylib` fix inlined directly in `meta.yaml`'s `build/script` block | Script grows very long inside `meta.yaml`; hard to read and maintain |
| [`phase-7b_macos-cpu-buildsh`](phase-7b_macos-cpu-buildsh/) | Same macOS fix refactored into `build.sh` + `bld.bat` + `macos_helper.sh` | Good pattern, but still a separate CPU-only recipe; CUDA wasn't unified yet |
| [`phase-8_pre-final-cuda`](phase-8_pre-final-cuda/) | Separate `pygenn-cuda` package for Linux and Windows using a tagged release tarball (`5.3.0_RC1`) | Two separate packages (`pygenn-cpu` + `pygenn-cuda`) mean users must pick the right one; Conda-Forge reviewers requested a single unified recipe using `{{ compiler('cuda') }}` |

### `phase-8_pre-final-cuda/early-tests/`
Contains two development test scripts from the project root:
- `run_pygenn_cuda_smoketest.py` — early iteration of the CUDA smoketest (the final version is in `../Conda_Forge/pygenn-suite/tests/`)
- `test.py` — a VA benchmark simulation (4000 LIF neurons) used to manually validate a CUDA build end-to-end

---

## Key Turning Points

**Challenge 1 — CUDA 11.7 → modular 12.x (phases 1 → 3 → 4)**  
Conda-Forge moved from a single `cudatoolkit` to modular packages (`cuda-nvcc`, `cuda-cudart-dev`, `cuda-cccl`, etc.). Phase 3 pins to `12.4`; phase 4 generalises with `cuda-version ==`.

**Challenge 2 — `CUDA_PATH` not set after install (resolved in phase 8 / final)**  
The `post-link.sh` / `post-link.bat` scripts (introduced in `phase-8_pre-final-cuda/`) print a message guiding users to `export CUDA_PATH=$CONDA_PREFIX`.

**Challenge 3 — Windows runtime compile (phases 6a → 6b)**  
Phase 6a used MSBuild only, which can compile the package but not the user's generated CUDA kernels at runtime. Phase 6b introduced the NMake + MSBuild hybrid and the `CUDA_LIBRARY_PATH` variable (aligned with PR #705 in the genn repo).

**Challenge 4 — macOS `.dylib` handling (phases 7a → 7b)**  
`setup.py` didn't copy `libgenn_dynamic.dylib` into `site-packages` on macOS. Phases 7a/7b add explicit copy + `install_name_tool` patching. The underlying fix was also upstreamed as PR #707 in the genn repo.

**Final unification (phase 8 → `Conda_Forge/pygenn-suite`)**  
Conda-Forge reviewers asked for a single recipe. The final recipe uses `{{ compiler('cuda') }}` and a `cuda_compiler_version` guard to produce both `cpu*` and `cuda*` build-string variants from one `meta.yaml`.
