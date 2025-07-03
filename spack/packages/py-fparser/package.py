# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

""" This module extends fparser Spack installation recipe in the
upstream Spack repository, https://github.com/spack/spack, namely
'spack/var/spack/repos/builtin/packages/py-fparser/package.py'.
Extending the recipe may be required when we need to deploy a new fparser
release but the upstream repository does not yet have the changes merged."""

from importlib import import_module

fparser = import_module("spack.pkg.builtin.py-fparser")


class PyFparser(fparser.PyFparser):
    """
    This class extends `fparser.PyFparser` class from the related
    Spack installation 'package.py' build recipe.

    fparser is based upon the Fortran parser
    originally developed by Pearu Peterson for the F2PY project,
    www.f2py.com. It provides a parser for Fortran source code
    (up to and including F2008) implemented purely in Python with
    minimal dependencies.

    """

    # Extend the versions
    version("master", branch="master")
    version(
        "0.2.0",
        sha256="3901d31c104062c4e532248286929e7405e43b79a6a85815146a176673e69c82")
    version(
        "0.1.3",
        sha256="10ba8b2803632846f6f011278e3810188a078d89afcb4a38bed0cbf10f775736"
    )
