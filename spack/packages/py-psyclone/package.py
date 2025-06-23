# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

""" This module extends PSyclone Spack installation recipe in the
upstream Spack repository, https://github.com/spack/spack, namely
'spack/var/spack/repos/builtin/packages/py-psyclone/package.py'.
Extending the recipe may be required when we need to deploy a new PSyclone
release but the upstream repository does not yet have the changes merged."""

from importlib import import_module

psyclone = import_module("spack.pkg.builtin.py-psyclone")


class PyPsyclone(psyclone.PyPsyclone):
    """
    This class extends `psyclone.PyPSyclone` class from the related
    Spack installation 'package.py' build recipe.

    PSyclone is a source-to-source Fortran compiler designed to
    programmatically optimise, parallelise and instrument HPC applications
    (written in Fortran) via user-provided transformation scripts.
    Additionally, PSyclone supports the development of kernel-based,
    Fortran-embedded DSLs and is used in the UK
    Met Office's next-generation modelling system, LFRic.

    """

    # Extend the links
    pypi = "PSyclone/psyclone-3.1.0.tar.gz"

    # Extend the versions
    version("master", branch="master")
    version(
        "3.1.0",
        sha256="7b369353942358afcb93b199ef2b11116d756cf9d671667ca95fa83fb31f0355")
    version(
        "3.0.0",
        sha256="25085a6d0dad36c03ec1f06becf7e2f915ded26603d4a1a2981392f5752fdb3e")

    # Extend the dependencies
    depends_on("py-fparser@0.2.0:", type=("build", "run"), when="@3.0.0:")
    depends_on("py-setuptools", type="build")
    depends_on("py-pyparsing", type=("build", "run"))
    depends_on("py-graphviz", type=("build", "run"))
    depends_on("py-configparser", type=("build", "run"))
    depends_on("py-jinja2", type="build")
    depends_on("py-jsonschema", type=("build", "run"), when="@2.5.0:")
    depends_on("py-sympy", type=("build", "run"), when="@2.2.0:")
    depends_on("py-termcolor", type=("build", "run"))

    # Define runtime environment variables for PSyclone
    # configuration and libraries in the LFRic software stack
    def setup_run_environment(self, env):
        """
        Define runtime environment variables for the location of
        PSyclone configuration file and wrapper libraries:
        PSYCLONE_CONFIG=$PACKAGE_DIR/share/psyclone/psyclone.cfg
        PSYCLONE_LIB_DIR=$PACKAGE_DIR/share/psyclone/lib

        """
        env.set("PSYCLONE_CONFIG",
                join_path(self.spec.prefix.share.psyclone, "psyclone.cfg"))
        env.set("PSYCLONE_LIB_DIR", self.spec.prefix.share.psyclone.lib)
