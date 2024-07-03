# Environments

A directory for each buildable environment

## Contents

- `conda.yaml`: Conda environment definition
- `spack.yaml`: Spack environment definition
- `post-install.sh`: Extra commands to run after creating the spack and conda environments
- `etc/`: Extra files to copy into the environment directory
  - `etc/env.activate.sh`: Sourced when the environment is activated
