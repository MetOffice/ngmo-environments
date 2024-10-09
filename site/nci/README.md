# NCI Gadi Containers

Containers are built similar to the apptainer site, but in two stages. The
first stage runs in 'copyq' which has internet access, the second stage runs on
the compute nodes for faster builds.

NCI containers make use of NCI's pre-installed compilers and MPI. Images are not
portable to other sites, for portable images use the `apptainer` site directory.

## Building the environment

A container can be built with

```bash
# Install an environment
./site/nci/install.sh lfric
```

By default the container will be installed into
`/scratch/$PROJECT/$USER/ngmo-envs`. Modules are provided, which can be loaded
with:

```bash
module use /scratch/$PROJECT/$USER/ngmo-envs/modules
module load ngmo-envs/lfric
```

## Using container environments

Make sure the container environment's `bin/` directory is on your `PATH`, e.g.
by loading the module:

```bash
module use /scratch/$PROJECT/$USER/ngmo-envs/modules
module load ngmo-envs/lfric
```

Run commands inside the container using the `envrun` script. If you build an
executable inside the container you must also run it inside the container.

```
envrun make
envrun mpirun -n 6 lfric
```

## Developing environments

Develop environments in our local mirror of this repository at
https://git.nci.org.au/bom/ngm/ngmo-environments/. CI is set up to
automatically build branches, the built environments are usable with

```
module use /scratch/hc46/hc46_gitlab/ngm/modules
module load ngmo-envs/lfric/$BRANCH
```

Once a change has been developed locally create a pull request on the Met
Office repository https://github.com/metoffice/ngmo-environments to make it
available at all sites.

Builds off of the Met Office repository are usable with

```
module use /g/data/access/ngm/modules/envs
module load lfric
```
