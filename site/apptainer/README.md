# Apptainer containers

Containers for working with Apptainer or Singularity

## Prerequisites

The container build requires apptainer and mksquashfs.

If not centrally available apptainer and mksquashfs can be installed using
conda, e.g.

```bash
conda create -n apptainer apptainer squashfuse

export APPTAINER=(conda run -n apptainer apptainer)
export MKSQUASHFS=(conda run -n apptainer mksquashfs)
```

## Building containers

A container can be built with

```bash
# Configure where environments are installed
export NGMOENVS_BASEDIR=~/ngmo-envs

# Configure the compiler and MPI to use
export NGMOENVS_COMPILER=gcc
export NGMOENVS_MPI=openmpi@4

# Install an environment
./site/apptainer/install.sh lfric
```

Building some packages will require passwordless access to MOSRS which will need
to be set up separately.

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

## Using Host MPI

TODO
