# Apptainer containers

Containers for working with Apptainer or Singularity

## Installing apptainer

On a VM apptainer can be installed with

```bash
conda create -n apptainer apptainer squashfuse
```

## Building containers

```bash
# What is your apptainer command?
export APPTAINER="conda run -n apptainer apptainer"

# Or with central installation
# export APPTAINER=$(which apptainer || which singularity)

# Configure where environments are installed
export NGMOENVS_BASEDIR=~/ngmo-envs

# Configure the compiler and MPI to use
export NGMOENVS_COMPILER=gcc
export NGMOENVS_MPI=openmpi@4

# The environment to install
export ENV=lfric

./site/apptainer/install.sh $ENV
```
