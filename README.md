# ngmo-environments
Next Generation Environments for Momentum

## Contents

* `sites/`: Site specific build scripts
* `environments/`: Environment definitions
* `packages/`: Spack and Conda package definitions
* `utils/`: Shared scripts

## Using NGMO Environments

Using the Conda and Spack package managers equivalent environments can be
created across multiple sites. For sites that can use containers containerised
versions of the environments can also be built.

To simplify usage across sites, a wrapper command `envrun` is used that will
load the environment and run a command inside it. This wrapper command can
abstract container arguments, environment modules and other local features.

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
