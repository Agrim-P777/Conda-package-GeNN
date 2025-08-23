## Pygenn-cpu (mac02)

Modular `pygenn-cpu` package with different script files:

`conda-build` has built-in defaults:

- **On Linux & macOS** → if a file called **`build.sh`** exists in the recipe directory, it will run it automatically.
- **On Windows** → if a file called **`bld.bat`** exists, it will run that automatically.
- **If neither exists**, then it looks at the `build/script:` section in `meta.yaml`.

So the order of precedence is:

1. If you define `build/script:` inside `meta.yaml`, that’s used.
2. If no `build/script:` but `build.sh` exists → run `bash build.sh` on Linux/macOS.
3. If no `build/script:` but `bld.bat` exists → run `bld.bat` on Windows.

With this setup "`pygenn-cpu (mac02)`", removing `build/script:` means:

- On macOS/Linux, conda-build will just invoke  `build.sh`.
- On Windows, conda-build will invoke  `bld.bat`.

No extra configuration is needed, and no "script" section needed under "build" in `meta.yaml`
