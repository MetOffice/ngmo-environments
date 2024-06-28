# Sites

A directory for each site environments can be created on

## Example sites

 * aws: Installs an uncontainerised environment on an AWS instance, should be
   adaptable to most VM types
 * apptainer: Installs a containerised environment
 * nci: Installs a containerised environment in two stages, one that requires
   network access and one that requires compute

For the most part sites do some site-specific setup and then call the generic
installation scripts from `../utils/`.

## Common environment variables

These variables can be used to control the installation for most sites. Export the variables before running the install scripts, e.g.
```
export NGMOENVS_BASEDIR="/scratch/$PROJECT/ngmo-envs"
export NGMOENVS_COMPILER="ifort"
export NGMOENVS_MPI="openmpi@4"

./site/apptainer/install.sh lfric
```

 * `NGMOENVS_BASEDIR`: Base directory for installing environments under.
   Environments will be installed under `$NGMOENVS_BASEDIR/envs`. If using the
   bootstrap task spack and conda will also be installed under
   `$NGMOENVS_BASEDIR/spack` and `$NGMOENVS_BASEDIR/conda` respectively.
 * `$NGMOENVS_ENVDIR`: Specific directory for installing an environment under if
   not using the default.
 * `$NGMOENVS_COMPILER`: Compiler to use for Spack packages
 * `$NGMOENVS_MPI`: MPI to use for Spack packages
 * `$NGMOENVS_SPACK_MIRROR`: Path for storing built spack packages, default `file://$NGMOENVS_BASEDIR/spack-mirror`.
 * `$CONDA_BLD_PATH`: Path for storing built conda packages, default `$NGMOENVS_BASEDIR/conda-bld`.
