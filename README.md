[![Google Summer of Code](assets/gsoc-banner.png)](https://summerofcode.withgoogle.com/)

---

## Project Repository

[Conda-package-GeNN](https://github.com/Agrim-P777/Conda-package-GeNN)  
This repository contains *all the code, packaging recipes, and documentation* developed during my Google Summer of Code project.

---

# Table of Contents
- [Repository Structure](#repository-structure)
- [Google Summer of Code (GSoC)](#google-summer-of-code-gsoc)
- [About INCF](#about-incf)
- [About GeNN](#about-genn)
- [Problem Statement](#problem-statement)
  - [Deliverables](#deliverables)
- [Rise of CUDA in Neural Simulations](#rise-of-cuda-in-neural-simulations)
- [Why Conda (and not PyPI)](#why-conda-and-not-pypi)
- [Package Architecture](#package-architecture)
- [Challenges Faced and Solutions](#challenges-faced-and-solutions)
  - [Challenge 1: Transition from CUDA <12.x to CUDA ≥12.x](#challenge-1-transition-from-cuda-12x-to-cuda-12x)
  - [Challenge 2: Setting CUDA_PATH After Installation](#challenge-2-setting-cuda_path-after-installation)
  - [Challenge 3: Moving Windows Build to NMake + MSBuild](#challenge-3-moving-windows-build-to-nmake--msbuild)
  - [Challenge 4: Fixing macOS .dylib Handling in pygenn-cpu](#challenge-4-fixing-macos-dylib-handling-in-pygenn-cpu)
- [Conda-Forge Packages](#conda-forge-packages)
- [Impact of the Package](#impact-of-the-package)

---
## Repository Structure

```
Conda-package-GeNN/
├── Conda_Forge/pygenn-suite/   ← Final recipe submitted to Conda-Forge (source of truth)
├── dev/                        ← All intermediate recipes from the development process
│   ├── phase-1_linux-cuda11.7/          First CUDA recipe (monolithic cudatoolkit 11.7)
│   ├── phase-2_linux-cpu/               First CPU recipe (Linux-only)
│   ├── phase-3_linux-cuda12.4/          Modular CUDA, pinned to 12.4
│   ├── phase-4_linux-cuda12.x/          Generalized to all CUDA 12.x versions
│   ├── phase-5a_windows-cpu/            Windows CPU recipe exploration
│   ├── phase-5b_cross-platform-cpu/     Cross-platform CPU (Linux/macOS/Windows)
│   ├── phase-5c_winlinux-cpu/           Refined CPU recipe (Windows+Linux, pin_compatible numpy)
│   ├── phase-6a_windows-cuda-msbuild/   Windows CUDA with MSBuild only
│   ├── phase-6b_windows-cuda-nmake/     Windows CUDA with NMake+MSBuild hybrid (PR #705)
│   ├── phase-7a_macos-cpu-inline/       macOS dylib fix inlined in meta.yaml
│   ├── phase-7b_macos-cpu-buildsh/      macOS dylib fix refactored into build.sh (PR #707)
│   └── phase-8_pre-final-cuda/          Separate pygenn-cuda package (pre-unification)
│       ├── early-tests/                 Early VA benchmark + CUDA smoketest
│       └── tests/                       CUDA smoketest for this recipe
└── assets/                     Images used in this README
```

See [dev/README.md](dev/README.md) for a phase-by-phase explanation of what each recipe tried, what broke, and why it was replaced.

---
## Google Summer of Code (GSoC)

[Google Summer of Code (GSoC)](https://summerofcode.withgoogle.com/) is an annual global program focused on bringing new contributors into open source software development.  
Contributors work with open source organizations under the guidance of mentors to learn, code, and make impactful contributions during the summer.

---

### GSoC 2025 Highlights
- **15,240 applicants** from **130 countries** submitted **23,559 proposals**  
- **185 mentoring organizations** selected **1,272 contributors** from **68 countries**  
- **66.3% of contributors** had *no prior open source experience*, showing GSoC’s accessibility  
- A **three-week Community Bonding period** helps contributors and mentors plan and get oriented before coding  

[Read more on the official announcement](https://opensource.googleblog.com/2025/05/gsoc-2025-we-have-our-contributors.html)

---

## About INCF

[![INCF](assets/incf-banner.jpg)](https://www.incf.org/)  
The [International Neuroinformatics Coordinating Facility (INCF)](https://www.incf.org/) is an open and FAIR (Findable, Accessible, Interoperable, and Reusable) neuroscience standards organization.  
Launched in 2005 through a proposal from the OECD Global Science Forum, INCF’s mission is to make neuroscience data and knowledge **globally shareable and reusable**.

---
### Impact on Society
By developing community-driven standards and tools for data sharing, analysis, modeling, and simulation, INCF:
- Promotes **collaboration** across international neuroscience communities  
- Enables **reproducible and scalable research**  
- Accelerates **discoveries in brain science**  
- Supports better understanding of brain function in both **health and disease**  

Through these efforts, INCF helps build a more open scientific ecosystem, ultimately contributing to advances in healthcare, mental health, and neurological research worldwide.

---
## About GeNN

[![GeNN](assets/genn-banner.png)](https://genn-team.github.io/)  
The [GPU-enhanced Neuronal Networks (GeNN)](https://genn-team.github.io/) project is a code generation framework designed to accelerate the simulation of spiking neural networks (SNNs) using GPUs.  

#### Role in Neuroscience
GeNN plays a crucial role in computational neuroscience by:
- Enabling **fast and efficient simulation** of large-scale spiking neural networks  
- Allowing researchers to **prototype and test brain-inspired models** at unprecedented scales  
- Supporting **reproducibility and standardization** in neural simulations  
- Bridging the gap between **biological realism and computational efficiency**  

Through its GPU acceleration, GeNN empowers neuroscientists to explore complex models of brain function that would otherwise be computationally prohibitive.

---
## Problem Statement

[GeNN](https://genn-team.github.io/) is a **C++ library** that generates code for efficiently simulating **Spiking Neural Networks (SNNs)** using GPUs.  
To compile the generated code, GeNN requires a **C++ compiler** and development versions of backend dependencies such as **CUDA**.  

Currently, this means GeNN must be **installed from source**, which can be a barrier for many potential users:
- Researchers may not have the right compiler or CUDA version installed
- Installation errors can take hours to resolve
- New users may be discouraged before even running their first simulation

---
###  Project Goal

For this project, I aimed to develop a **Conda (Forge) package** for GeNN which:
- Handles the installation of all required dependencies (C++, CUDA, libraries)
- Provides pre-built binaries for Linux, Windows, and macOS
- Makes installation as simple as:

  ```bash
  conda install -c conda-forge pygenn-cpu   # CPU-only
  conda install -c conda-forge pygenn-cuda  # CUDA-enabled
---

###  Deliverables

- Conda-Forge recipes for both **CPU** and **CUDA** variants of GeNN
- User documentation and installation instructions
---

## Rise of CUDA in Neural Simulations
[![NVIDIA](assets/nvidia-cuda-banner.jpg)](https://developer.nvidia.com/cuda-toolkit)  

The introduction of **CUDA (Compute Unified Device Architecture)** by NVIDIA revolutionized the way scientists and engineers simulate neural networks.  

### Why CUDA Matters
- Provides **massive parallelism** by leveraging thousands of GPU cores  
- Accelerates **matrix operations** and **synaptic updates** critical for spiking neural networks  
- Reduces simulation times from **hours or days to minutes or seconds**  
- Allows scaling to **millions of neurons and synapses** in realistic brain models  

### Impact on Neuroscience
By harnessing CUDA, researchers can:
- Explore **biologically detailed models** of neural circuits  
- Run **real-time simulations** for robotics and brain-inspired AI  
- Investigate complex dynamics of the brain that were previously infeasible due to computational limits  

In short, CUDA has been a **key enabler** in advancing computational neuroscience and the adoption of frameworks like **GeNN**.

---
##  Why Conda (and not PyPI)

We chose **Conda** because our package is not just Python — it also includes a **C++ backend and CUDA code**.  

- Conda can package **non-Python dependencies** (C++, CUDA, compilers, system libraries), while PyPI is limited to Python-only distributions.  
- With Conda we can **pin CUDA versions and compilers**, ensuring compatibility across Linux, Windows, and macOS.  
- This makes Conda the better choice for distributing GPU-accelerated scientific software like **GeNN**, where reproducibility and native dependencies are critical.  

---
## Package Architecture
[![Conda-Forge](assets/conda-forge.png)](https://conda-forge.org/)  

We designed the package to provide **two build variants** of GeNN:

1. **CPU-only**  
   - Lightweight build that works without CUDA  
   - Useful for users who want to experiment with spiking neural networks on any system  

2. **CUDA-enabled**  
   - Full GPU acceleration using modular CUDA packages  
   - Ideal for large-scale neuroscience simulations  

---
###  Structure
- A **single unified recipe** (`Conda_Forge/pygenn-suite/`) produces both CPU and CUDA variants from one `meta.yaml` using the `{{ compiler('cuda') }}` / `cuda_compiler_version` guard
- The build string (`cpu*` vs `cuda*`) lets Conda automatically select the right variant based on whether an NVIDIA driver is present
- Each build pins Python, NumPy ABI, and (for CUDA builds) modular CUDA components like `cuda-nvcc`, `cuda-cudart`, `cuda-cccl`, and `libcurand-dev`
- Shared test suite (`tests/run_pygenn_cpu_smoketest.py` + `tests/run_pygenn_cuda_smoketest.py`) ensures both variants behave correctly

> **Development history:** The recipe started as separate `pygenn-cpu` and `pygenn-cuda` packages. After Conda-Forge review feedback, they were merged into the unified `pygenn` recipe. See [`dev/`](dev/) for the full iteration history.

This unified approach makes GeNN more **accessible and reproducible**, whether on laptops or GPU clusters.  

[Read more on the detailed package structure](https://github.com/Agrim-P777/Conda-package-GeNN/wiki/05.-GeNN-%E2%80%90-Conda-Package-Structure:-CPU%E2%80%90Only-and-CUDA%E2%80%90Enabled)

---
##  Challenges Faced and Solutions

### Challenge 1: Transition from CUDA <12.x to CUDA ≥12.x

Initially, our package was built for **CUDA 11.7**, which used a **monolithic toolkit package**.

[Example: CUDA 11.7 recipe](dev/phase-1_linux-cuda11.7/meta.yaml)

However, starting with **CUDA 12.x**, Conda-Forge adopted a **modular CUDA packaging** system:

- Instead of a single `cudatoolkit` package
- CUDA is split into components like `cuda-nvcc`, `cuda-cudart`, `cuda-libraries`, `cuda-libraries-dev`, etc.

[Detailed explanation: Pre-12 vs Post-12 CUDA packaging](https://github.com/Agrim-P777/Conda-package-GeNN/wiki/06.-Understanding-CUDA-Packaging-in-Conda%E2%80%90Forge:-Pre%E2%80%9012-vs-Post%E2%80%9012-Versions)

###  Our Solution

- Migrated the recipe to **modular CUDA dependencies** in `meta.yaml`
- Explicitly pinned the CUDA version with:
    
    ```yaml
    - cuda-version =={{ cuda_version }}
    - cuda-nvcc {{ cuda_nvcc }}
    - cuda-cudart {{ cuda_cudart }}
    - cuda-libraries {{ cuda_libraries }}
    - cuda-libraries-dev {{ cuda_libraries_dev }}
    ```
    
- Ensured compatibility across **Linux, Windows, and macOS** by adjusting the build matrix and using Conda’s modular CUDA toolchain.

This transition was essential to keep the package **future-proof and aligned** with Conda-Forge’s evolving CUDA ecosystem.

###  Challenge 2: Setting `CUDA_PATH` After Installation

During testing, we discovered that after installing the CUDA-enabled package,

the **`CUDA_PATH` environment variable** was **not automatically set** in the Conda environment.

- This caused issues on both **Linux** and **Windows**, where users needed `CUDA_PATH` for compiling and running GeNN models.
- Without it, the CUDA backend could not be located properly by the build system.

[Reference: post-link script design](https://github.com/Agrim-P777/Conda-package-GeNN/wiki/08.-Including-a-post%E2%80%90link.sh-script-in-the-Conda-Package)

### Our Solution

- Added **`post-link.sh`** (Linux/macOS) and **`post-link.bat`** (Windows) scripts to the recipe.
- These scripts:
    - Notify users that they must export or set `CUDA_PATH` in their shell session
    - Provide clear guidance on how to configure it (`export CUDA_PATH=$CONDA_PREFIX` on Linux/macOS, `set CUDA_PATH=%CONDA_PREFIX%\\Library` on Windows)

**Example `post-link.sh` Script**

```bash
#!/bin/bash
echo ""
echo "============================================"
echo "PyGeNN CUDA backend installed successfully!"
echo ""
echo "To enable CUDA support, set the environment variable:"
echo "    export CUDA_PATH=$CONDA_PREFIX"
echo ""
echo "Alternatively, if you have a system-wide CUDA installation:"
echo "    export CUDA_PATH=/usr/local/cuda-12.x"
echo ""
echo "PyGeNN will automatically use CUDA_PATH if set; otherwise, you may"
echo "need to manually configure it for certain use cases."
echo "============================================"
echo ""
```

This ensures users are explicitly informed about the required step, making the installation process **clearer and less error-prone**.

###  Challenge 3: Moving Windows Build to NMake + MSBuild

Originally, the Windows build system relied only on **MSBuild**, which was insufficient to support conda pacakge's 
GeNN’s requirement for **runtime code compilation** of models.  

### Our Solution
- Migrated the Windows backend to a hybrid **NMake + MSBuild** system.  
- Benefits of this change:
  - Enabled **runtime compilation** of CUDA kernels on Windows  
  - Added **robust CUDA path management**, ensuring builds work with Conda’s modular CUDA layout  
  - Standardized the use of **`CUDA_LIBRARY_PATH`** across Windows environments for consistency  

This migration improved reliability and made the Windows build **much closer to Linux in flexibility**,  
while also aligning with Conda’s CUDA packaging best practices.  

[My Pull Request #705 – robust CUDA lib path resolution for Conda & system installs](https://github.com/genn-team/genn/pull/705)

### Challenge 4: Fixing macOS `.dylib` Handling in `pygenn-cpu`

When building the **CPU-only PyGeNN package** on macOS, we encountered an issue where  
the required **dynamic libraries (`.dylib`)** were **not being copied correctly** into the installed package directory.  
This caused runtime errors where Python could not locate GeNN’s backend libraries.

### Our Solution (My PR)
I submitted [PR #707](https://github.com/genn-team/genn/pull/707) to fix the **macOS library handling** in `setup.py`.  
Key technical improvements included:

- **Dynamic Library Discovery**  
  - Updated `setup.py` to explicitly find GeNN’s `.dylib` artifacts generated during the build process.  
  - Ensured both the **core `libgenn_dynamic.dylib`** and the **CPU backend libraries** were properly detected.  

- **Correct Copy into `site-packages`**  
  - Added logic to copy these `.dylib` files into the final `pygenn` installation directory under `site-packages`.  
  - This guarantees the Python extension modules can locate their linked dynamic libraries at runtime.  

- **macOS Loader Path Fixes**  
  - Adjusted the `install_name` handling so that macOS’s runtime linker resolves the `.dylib` files correctly.  
  - Prevented the “image not found” errors that occurred when relocating the package to a Conda environment.  

### Impact
- Resolved **import-time failures** on macOS for the `pygenn-cpu` package.  
- Improved **cross-platform parity**, since Linux `.so` handling was already stable.  
- Made the CPU-only build truly **portable** across Conda environments on macOS.  

[My Pull Request #707 – macOS `.dylib` fix in setup.py](https://github.com/genn-team/genn/pull/707)

---
## Conda-Forge Packages

After resolving build system and packaging challenges, we contributed to the **official Conda-Forge recipes** for PyGeNN.

### Published Packages

Initial staged-recipes submissions (separate packages, then consolidated):
- **pygenn-cuda** → [staged-recipes PR #30899](https://github.com/conda-forge/staged-recipes/pull/30899)
    - GPU-accelerated build with modular CUDA support
    - Targets Linux and Windows with reproducible CUDA environments
- **pygenn-cpu** → [staged-recipes PR #30907](https://github.com/conda-forge/staged-recipes/pull/30907)
    - Lightweight CPU-only build
    - Cross-platform support (Linux, Windows, macOS) without CUDA dependency

These were subsequently merged into a **single unified `pygenn` recipe** ([`Conda_Forge/pygenn-suite/`](Conda_Forge/pygenn-suite/)) that builds both variants from one `meta.yaml`.

### Impact

- Brought **PyGeNN to the Conda-Forge ecosystem**, making installation as simple as:
    
    ```bash
    conda install -c conda-forge pygenn-cpu   # CPU-only
    conda install -c conda-forge pygenn-cuda  # CUDA-enabled
    ```
- Improved **discoverability, reproducibility, and accessibility** for neuroscience researchers and developers worldwide.

---
## Impact of the Package

Before our Conda-Forge packages, users had to **install GeNN from source**:  
- Clone the repository  
- Configure compilers and CUDA toolchains manually  
- Build the C++ backend  
- Troubleshoot platform-specific errors (Linux, Windows, macOS)  

This process was **time-consuming and error-prone**, often taking **hours** for new users.

### Improvements with Conda Packages
- Installation reduced to a **single command**:  
  ```bash
  conda install -c conda-forge pygenn-cpu   # CPU-only
  conda install -c conda-forge pygenn-cuda  # CUDA-enabled
  ```
- **No manual compilation** needed — all binaries are pre-built for the target platform
- **Cross-platform availability**: Linux, Windows, and macOS
- **Pinned toolchains and CUDA versions** ensure reproducibility and stability
- Eliminates setup barriers, letting researchers focus on **science, not build systems**

### Impact on Researchers

- Decreased installation time from **hours → minutes**
- Made GeNN accessible to **a wider audience**, including those without deep build/DevOps expertise
- Strengthened the reliability of **neuroscience workflows** by providing reproducible environments

In short, this packaging effort turned GeNN from a **complex source-based project** into an **accessible plug-and-play library** for the neuroscience community!
