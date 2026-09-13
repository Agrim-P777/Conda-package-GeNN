@echo on
REM ===========================
REM Windows build for pygenn-cpu
REM ===========================

@REM REM Force short build path to avoid Windows path length issues
@REM set "CONDA_BLD_PATH=C:\bld"

REM CPU-only: disable CUDA
set "CUDA_PATH="

REM Install the package
"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit /b 1
