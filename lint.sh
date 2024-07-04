#!/bin/bash

set -eu
set -o pipefail

find . -name \*.sh -print0 | xargs -0 shellcheck

prettier --write .

grep -r TODO .
