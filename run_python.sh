#!/bin/bash
source /c/ProgramData/miniforge3/etc/profile.d/conda.sh
conda run -n panda_env python "$@"
