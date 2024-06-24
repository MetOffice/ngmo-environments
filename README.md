# ngmo-environments
Next Generation Environments for Momentum

## Contents

* `sites/`: Site specific build scripts
* `environments/`: Environment definitions
* `spack/`: Spack package definitions
* `conda/`: Conda package definitions
* `utils/`: Shared scripts

## Using NGMO Environments

Using the Conda and Spack package managers equivalent environments can be
created across multiple sites. For sites that can use containers containerised
versions of the environments can also be built.

To simplify usage across sites, a wrapper command `envrun` is used that will
load the environment and run a command inside it. This wrapper command can
abstract container arguments, environment modules and other local features.

E.g. for building and running LFRic in the NGMO LFRic environment:

```bash
export PATH=$NGMOENVS_BASEDIR/envs/lfric/bin:$PATH

# App to build from lfric_apps/applications
APP=gravity_wave

# Build the app using `envrun`
envrun lfric_apps/build/local_build.py --application $APP

# Run the app example using `envrun`
cd lfric_apps/applications/$APP/example
envrun mpirun -n  1 ../bin/$APP configuration.nml
```

## Sites

### Apptainer

Build an Apptainer/Singularity container

See [site/apptainer/README.md](site/apptainer/README.md)

### AWS

Build the environment on Amazon Linux

See [site/aws/README.md](site/aws/README.md)

## Environments

### LFRic

Environment for running the Momentum LFRic model

See [environments/lfric/README.md](environments/lfric/README.md)
