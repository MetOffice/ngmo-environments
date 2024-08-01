#!/bin/bash

# Installs the environment
#
# Site files should be used to set up Conda and Spack to install in the right locations
#
# Configuration environment variables:
#   ENVIRONMENT: Environment name
#   NGMOENVS_ENVDIR: Environment install path
#   NGMOENVS_COMPILER: Compiler to build spack environment with
#   NGMOENVS_MPI: MPI to build spack environment with
#   NGMOENVS_SPACK_MIRROR: Spack build and source mirror
#   CONDA_BLD_PATH: Conda local build directory
#   NGMOENVS_DOWNLOAD_ONLY: Only download spack sources, don't build
#                           Builds are then done in `install-stage-two.sh`
#
# Creates a script $NGMOENVS_ENVDIR/bin/envrun that will run a command inside the environment

set -eu
set -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SCRIPT_DIR

source "$SCRIPT_DIR/common.sh"

# Path to install the environment to
: "${NGMOENVS_ENVDIR:="${NGMOENVS_BASEDIR}/envs/${ENVIRONMENT}"}"
export NGMOENVS_ENVDIR

: "${NGMOENVS_TMPDIR:=${TMPDIR:-/tmp}}"
export NGMOENVS_TMPDIR

# Path to base of this repo
export NGMOENVS_DEFS=${SCRIPT_DIR}/..

# Conda executable being used
: "${CONDA_EXE:=conda}"
export CONDA_EXE

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

info NGMOENVS_COMPILER="${NGMOENVS_COMPILER}"
info NGMOENVS_MPI="${NGMOENVS_MPI}"

# Path to environment definition
export ENVDEFS="${NGMOENVS_DEFS}/environments/${ENVIRONMENT}"
if [[ ! -d "$ENVDEFS" ]]; then
	error "Enviornment '$ENVIRONMENT' not found"
	exit 1
fi

export ENVDIR=$NGMOENVS_ENVDIR
mkdir -p "$ENVDIR"

# Install conda enviornment
if [[ -f "$ENVDEFS/conda.yaml" ]]; then
	# Build any required packages
	"$SCRIPT_DIR/build-conda-packages.sh"

	# Build the environment
	e "$CONDA_EXE" env create --yes --prefix "$ENVDIR/conda" --file "$ENVDEFS/conda.yaml"
fi

# Install spack environment
if [[ -f "$ENVDEFS/spack.yaml" ]]; then
	if [[ ! -d "$ENVDIR/spack" ]]; then
		# Create the environment if it doesn't exist
		e spack env create --dir "$ENVDIR/spack"
	else
		# Environment exists, make a new def file
		echo 'spack: {}' > "$ENVDIR/spack/spack.yaml"
	fi
	rm -f "$ENVDIR/spack/spack.lock"

	# Copy in the environment definitions
	cp "$ENVDEFS/spack.yaml" "$ENVDIR/spack/spack.yaml"

	# Install the compiler - the compiler lives outside the environment
	"${SCRIPT_DIR}/install-compiler.sh"

	# Activate the environment
	spack env activate "$ENVDIR/spack"

        # Add generic configs
        e spack config add --file "$SCRIPT_DIR/spack-packages.yaml"
	
	# Add the local packages if they're not already available
	e spack repo add "$NGMOENVS_DEFS/spack" || true

	# Add package binary mirror
	if [[ -n "${NGMOENVS_SPACK_MIRROR:-}" ]]; then
		e spack mirror add --autopush --unsigned ngmo-spack-local "$NGMOENVS_SPACK_MIRROR"
	fi

	# Add site config
	if [[ -f "$SITE_DIR/spack-packages.yaml" ]]; then
		e spack config add --file "$SITE_DIR/spack-packages.yaml"
	fi

	# Add compiler and mpi requirements
	e spack config add "packages:all:require:'%${NGMOENVS_COMPILER}'"
	e spack config add "packages:mpi:require:'${NGMOENVS_MPI}'"

        e spack config blame

	# Solve dependencies
	e spack concretize --fresh

	# Install everything
        if [[ ! -v NGMOENVS_DOWNLOAD_ONLY ]]; then
            e spack install
        else
            # Only download data to the mirror for later build
            e spack mirror create --directory "${NGMOENVS_SPACK_MIRROR#file://}" --all
        fi
fi

mkdir -p "$ENVDIR/bin"

# Post install steps - copy in etc and run post-install
if [[ -d "$ENVDEFS/etc" ]]; then
	e cp -r "$ENVDEFS/etc" "$ENVDIR"
fi
if [[ -f "$ENVDEFS/post-install.sh" ]]; then
	e "$ENVDEFS/post-install.sh"
fi

# Activate script
cat > "$ENVDIR/bin/activate" <<EOF
#!/bin/bash
export NGMOENVS_ENVIRONMENT="$ENVIRONMENT"
export NGMOENVS_ENVDIR="$ENVDIR"
export NGMOENVS_COMPILER="$NGMOENVS_COMPILER"
export NGMOENVS_MPI="$NGMOENVS_MPI"

spack env activate "\$NGMOENVS_ENVDIR/spack"
eval "\$(conda shell.bash activate "\$NGMOENVS_ENVDIR/conda")"

if [[ -f "\$NGMOENVS_ENVDIR/etc/env.activate.sh" ]]; then
	source "\$NGMOENVS_ENVDIR/etc/env.activate.sh"
fi
EOF

# Set compiler variables
cat "$ENVDIR/etc/compiler.sh" >> "$ENVDIR/bin/activate"

# Run script
cat > "$ENVDIR/bin/envrun" <<EOF
#!/bin/bash
# Run a command in the environment

source "$ENVDIR/bin/activate"

eval "\$@"
EOF
chmod +x "$ENVDIR/bin/envrun"

cat <<EOF

Environment installed at

    $ENVDIR/

Run commands in the environment with

    $ENVDIR/bin/envrun \$COMMAND

EOF
