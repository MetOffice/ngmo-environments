#!/bin/bash

# Install all environment dependencies

set -eu
set -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

e() {
	echo "$@"
	"$@"
}

SPACK_VERSION=0.22.0
export SPACK_DISABLE_LOCAL_CONFIG=1

mkdir -p "$NGMOENVS_BASEDIR/bin"
pushd "$NGMOENVS_BASEDIR" > /dev/null

if [[ ! -f "bin/micromamba" ]]; then
	curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar xj bin/micromamba	
fi

export MAMBA_ROOT_PREFIX="$NGMOENVS_BASEDIR/conda"
e "$NGMOENVS_BASEDIR/bin/micromamba" install -n base conda conda-build
source "$NGMOENVS_BASEDIR/conda/etc/profile.d/conda.sh"

if [[ ! -d "spack" ]]; then
	mkdir spack
	curl -Ls "https://github.com/spack/spack/releases/download/v${SPACK_VERSION}/spack-${SPACK_VERSION}.tar.gz" | tar -xz -C spack  --strip-components=1
fi
export SPACK_PYTHON="$NGMOENVS_BASEDIR/conda/bin/python"
source "$NGMOENVS_BASEDIR/spack/share/spack/setup-env.sh"

# Configure Spack
e spack compiler find --scope site /usr/bin
e spack external find --scope site --path /usr/bin gcc

# Create the activate script
cat > bin/activate << EOF
#!/bin/bash
# Source this file to load the bootstrap conda and spack

export SPACK_PYTHON="$NGMOENVS_BASEDIR/conda/bin/python"
source "$NGMOENVS_BASEDIR/conda/etc/profile.d/conda.sh"
source "$NGMOENVS_BASEDIR/spack/share/spack/setup-env.sh"

# Disable .spack and /etc/spack directories
export SPACK_DISABLE_LOCAL_CONFIG=1

# Set default paths
: \${NGMOENVS_BASEDIR:="$NGMOENVS_BASEDIR"}
: \${NGMOENVS_COMPILER:="$(spack spec --format '{compiler.name}@{compiler.version}' mpi)"}
: \${NGMOENVS_MPI="$(spack spec --format '{name}@{version}' mpi)"}

export NGMOENVS_BASEDIR
export NGMOENVS_COMPILER
export NGMOENVS_MPI
EOF
source "$NGMOENVS_BASEDIR/bin/activate"

cat <<EOF

Bootstrap complete

Load micromamba and spack with

    source "$NGMOENVS_BASEDIR/bin/activate"
EOF
