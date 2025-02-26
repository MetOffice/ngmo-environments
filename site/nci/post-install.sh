#!/bin/bash

# Post-install tasks

set -eu
set -o pipefail

mkdir -p "$(dirname "$NGMOENVS_MODULE")"
cat > "$NGMOENVS_MODULE" << EOF
#%Module1.0

set name         "$ENVIRONMENT"
set version      "$VERSION"
set origin       "$(git remote get-url origin) $(git rev-parse HEAD)"
set install_date "$(date --iso=minute)"
set installed_by "$USER - $(getent passwd "$USER" | cut -d ':' -f 5)"
set prefix       "$INSTALL_ENVDIR"

proc ModulesHelp {} {
    global name version origin install_date installed_by

    puts stderr "NGMO Environment \$name/\$version"
    puts stderr "  Install info:"
    puts stderr "    repo: \$origin"
    puts stderr "    ver:  \$version"
    puts stderr "    date: \$install_date"
    puts stderr "    by:   \$installed_by"
}

set name_upcase [string toupper [string map {- _} \$name]]

setenv \${name_upcase}_ROOT "\$prefix"
setenv \${name_upcase}_VERSION "\$version"

prepend-path PATH "\$prefix/bin"
EOF

mkdir -p "$INSTALL_ENVDIR/bin"

# If installing through a container use the site-specific 'envrun',
# if not then the default will get installed
for script in envrun envrun-wrapped; do
    if ! [[ -f "$INSTALL_ENVDIR/bin/$script" ]]; then
        cp "$SITE_DIR/$script" "$INSTALL_ENVDIR/bin"
        chmod +x "$INSTALL_ENVDIR/bin/$script"
    fi
done

# Old launcher name
ln -sf "envrun" "$INSTALL_ENVDIR/bin/imagerun"

# Make rose commands run inside the container
ln -sf "envrun-wrapped" "$INSTALL_ENVDIR/bin/rose"

cat <<EOF

Environment build complete

Load the environment with

    module load "$NGMOENVS_MODULE"

Prepend commands with 'envrun' to run them in the container
EOF
