# Pawsey Setonix Containers

Containers are built similar to the apptainer site, but in two stages. The
first stage runs in 'copyq' which has internet access, the second stage runs on
the compute nodes for faster builds.

Pawsey containers make use of Pawsey's pre-installed compilers and MPI. Images are not
portable to other sites, for portable images use the `apptainer` site directory.

## Building the environment

A container can be built with

```bash
# Install an environment
./site/pawsey/install.sh lfric
```

## Using environments

By default the environments will be installed into
`/scratch/$PAWSEY_PROJECT/$USER/ngmo-envs/envs/$ENVIRONMENT/$BRANCH`.

Make sure the environment's `bin/` directory is on your `PATH`, e.g.
by loading the module:

```bash
module use /scratch/$PAWSEY_PROJECT/$USER/ngmo-envs/modules
module load lfric
```

Run commands inside the container using the `envrun` script. If you build an
executable inside the container you must also run it inside the container.

```
envrun make
envrun mpirun -n 6 lfric
```

A script `envrun-wrapped` is also provided, this can be symlinked to other
names to run the named command inside the environment:

```
ln -s /scratch/$PAWSEY_PROJECT/$USER/ngmo-envs/envs/lfric/master/bin/{envrun-wrapped,python}

# Now `python` will get run inside the environment
python
```
