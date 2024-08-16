#!/bin/bash

set -eu
set -o pipefail

touch rose_picker/__init__.py
sed rose_picker/rose_picker -e 's/^if __name__.*/def cli_main():/' > rose_picker/rose_picker.py

cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[project]
name = "lfric-gpl-utils"
version = "0.1"

[tool.setuptools.package-dir]
rose_picker = "rose_picker"
rose_lfric = "lib/python/rose_lfric"

[project.scripts]
rose_picker = "rose_picker.rose_picker:cli_main"
EOF

python3 -m pip install .

