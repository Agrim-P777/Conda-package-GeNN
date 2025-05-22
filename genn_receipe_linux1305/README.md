# GeNN Conda Package

This repository provides a conda package recipe for [GeNN (GPU-enhanced Neuronal Networks)](https://github.com/genn-team/genn), a code generation framework for GPU-accelerated spiking neural network simulations using CUDA.

---

## 📦 Package Overview

- **Name:** `genn`
- **Version:** `4.8.1`
- **Build Target:** Linux (x86_64)
- **Dependencies:**
  - CUDA Toolkit (via `cudatoolkit` and `cudatoolkit-dev`)
  - GCC (pinned to ensure compatibility with CUDA)
  - CMake
  - Make

---

## 🚀 Installation

### 🛠 Build the Conda Package

1. Clone this repository:

   ```bash
   git clone https://github.com/your-username/genn-conda-recipe.git
   cd genn-conda-recipe

## 🛠️ Install required conda tools

```bash
conda install conda-build boa -c conda-forge
```

## 📦 Build the package

```bash
conda build . --variant-config-files conda_build_config.yaml
```

## 📥 Install the built package

```bash
conda install --use-local genn
```

---

## ⚠️ System Requirements

### ❗ CUDA Driver Required

This package includes the CUDA toolkit runtime (e.g., `libcudart.so`), but **does not include** the NVIDIA driver (`libcuda.so`).  
You **must have the appropriate NVIDIA driver installed** on your system to run GeNN simulations.

---

## ✅ Check If Driver Is Installed

Run the following to verify your system has an NVIDIA GPU and the driver:

```bash
nvidia-smi
```

> CUDA 11.8 requires NVIDIA Driver version ≥ 510.x  
> You can download drivers from [NVIDIA's website](https://www.nvidia.com/Download/index.aspx)

---

## ✅ Verifying the Installation

You can check that GeNN was installed by verifying the headers:

```bash
ls $CONDA_PREFIX/include/genn
```

Or test using a command like:

```bash
genn-buildmodel --help
```

*(if `genn-buildmodel` is included in future build targets)*

---

## 🧠 About GeNN

**GeNN** (GPU-enhanced Neuronal Networks) is a framework for generating code to simulate spiking neural networks using NVIDIA GPUs.  
It is highly customizable and integrates well with other neural simulators.

- **GitHub**: [https://github.com/genn-team/genn](https://github.com/genn-team/genn)
- **License**: MIT

---

## 🧑‍💻 Maintainers

`to be updated`

---

## 📝 License

This conda recipe is released under the **MIT License**.  
The GeNN project itself is also MIT-licensed and maintained by the **University of Sussex**.
