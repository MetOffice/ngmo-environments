#!/bin/bash

e() {
	echo "$@"
	"$@"
}

ENVDEFS="${SCRIPT_DIR}/../../environments/${ENVIRONMENT}"

if [[ ! -d "$ENVDEFS" ]]; then
	echo "Enviornment '$ENVIRONMENT' not found"
	exit 1
fi

mkdir -p "$ENVDIR"

# Install conda enviornment
if [[ -f "$ENVDEFS/conda.yaml" ]]; then
	# Build any required packages
	source "$SCRIPT_DIR/../../utils/build-conda-packages.sh"

	# Build the environment
	e conda env create --yes --prefix "$ENVDIR/conda" --file "$ENVDEFS/conda.yaml"
fi

# Install spack environment
if [[ -f "$ENVDEFS/spack.yaml" ]]; then
	if [[ ! -f "$ENVDIR/spack/spack.yaml" ]]; then
		# Create the environment if it doesn't exist
		e spack env create --dir "$ENVDIR/spack" "$ENVDEFS/spack.yaml"
	else
		# Environment exists, copy in def file
		cp "$ENVDEFS/spack.yaml" "$ENVDIR/spack/spack.yaml"
	fi

	# Activate the environment
	e spack env activate "$ENVDIR/spack"
	
	# Add the local packages if they're not already available
	e spack repo add "$SCRIPT_DIR/../../packages/spack" || true

	# Add site config
	if [[ -f "$SCRIPT_DIR/spack-config.yaml" ]]; then
		e spack config add --file "$SCRIPT_DIR/spack-config.yaml"
	fi

	# Add compiler and mpi
	spack config add "packages:all:require:'%${NGMOENVS_COMPILER}'"
	spack config add "packages:mpi:require:'${NGMOENVS_MPI}'"
	e spack add "${NGMOENVS_COMPILER}"

	# Solve dependencies
	e spack concretize --force --fresh

	# Install everything
	e spack install
fi

mkdir -p "$ENVDIR/bin"

# Post install steps
if [[ -d "$ENVDEFS/etc" ]]; then
	e cp -r "$ENVDEFS/etc" "$ENVDIR"
fi

# Activate script
cat > "$ENVDIR/bin/activate" <<EOF
#!/bin/bash

source "$NGMOENV_BASEDIR/etc/profile.d/conda.sh"

conda activate "$ENVDIR/conda"
spack env activate "$ENVDIR/spack"

if [[ -f "$ENVDIR/etc/env.activate.sh" ]]; then
	source "$ENVDIR/etc/env.activate.sh"
fi

alias deactivate="source $ENVDIR/bin/deactivate"
EOF

# Deactivate script
cat > "$ENVDIR/bin/deactivate" <<EOF
#!/bin/bash

conda deactivate
spack env deactivate
EOF

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

Run commands in the enviornment with

    $ENVDIR/bin/envrun $COMMAND

EOF
