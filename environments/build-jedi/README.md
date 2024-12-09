# JOPA Container

Contains the dependencies required to build mo-bundle and run JOPA

https://github.com/MetOffice/mo-bundle

# Building JOPA / mo-bundle

## NCI, with a container

1. Load the container

```
module use /g/data/access/ngm
module load envs/jopa
```

2. Build Jopa inside the container

```
cd mo-bundle

imagerun cmake --preset=bom-container --workflow
```

## Met Office VDI, no container

1. Install Spack, and activate with `$SPACK/share/spack/setup-env.sh`

2. Copy `configs/meto_vdi/*` to the Spack configuration directory (e.g. `~/.spack` or `$SPACK/etc/spack`)

3. Install and setup a compiler, e.g. GCC 9

```
spack install gcc@9
spack compiler find $(spack find --format='{prefix}' gcc@9)
```

4. Install the environment with GCC and MPICH

```
export SPACK_COMPILER="gcc@9"
export SPACK_MPI="mpich +slurm"

srun -q -n1 -c10 --mem=40G --time=120 env -u SLURM_NODELIST ./bin/install.sh jopa-v0
```

5. Activate the environment

```
spack load $SPACK_COMPILER
spack env activate jopa-v0
export SPACK_ENV_VIEW=$SPACK_ENV/.spack-env/view
```

6. Build mo-bundle

```
cd mo-bundle

cmake --preset=bom-container --workflow
```
