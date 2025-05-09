#!/bin/bash

# Logs and runs a command
e() {
	echo RUN "$@" >&2
	echo RUN "$@" >> install.log
	"$@" | tee -a install.log
}

# Logging routines
info() {
	echo INFO "$@" | tee -a install.log
}

warning() {
	echo WARNING "$@" | tee -a install.log
}

error() {
	echo ERROR "$@" | tee -a install.log
}

# Version defaults to current git branch
: "${VERSION="$(git symbolic-ref --short HEAD)"}"
export VERSION

# Don't consider ~/.spack
export SPACK_DISABLE_LOCAL_CONFIG=1
