# Apptainer containers

Containers for working with Apptainer or Singularity

## Installing apptainer

On a VM apptainer can be installed with

```bash
conda create -n apptainer apptainer squashfuse
```

## Building containers

A container can be built with

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

Building a container may require passwordless access to MOSRS

## Using container environments

Make sure the container environment's `bin/` directory is on your `PATH`:

```bash
export PATH=${NGMOENVS_BASEDIR}/envs/lfric/bin:$PATH
```

Run commands inside the container using the `envrun` script. If you build an
executable inside the container you must also run it inside the container.

```
envrun make
envrun mpirun -n 6 lfric
```
