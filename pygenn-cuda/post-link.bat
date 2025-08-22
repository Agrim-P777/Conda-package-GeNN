@echo off
setlocal enabledelayedexpansion

REM Conda provides %PREFIX% during post-link
set "MSG_FILE=%PREFIX%\.messages.txt"

(
  echo.
  echo ============================================
  echo PyGeNN CUDA backend installed successfully!
  echo.
  echo To enable CUDA support, set the environment variable:
  echo     set CUDA_PATH=%%CONDA_PREFIX%%
  echo.
  echo Alternatively, if you have a system-wide CUDA installation:
  echo     set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.x
  echo.
  echo PyGeNN will automatically use CUDA_PATH if set; otherwise, you may
  echo need to manually configure it for certain use cases.
  echo ============================================
  echo.
) > "%MSG_FILE%"

REM Also show immediately to user
type "%MSG_FILE%"

endlocal
exit /b 0
