# Copyright 2013-2024 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# ----------------------------------------------------------------------------
# If you submit this package back to Spack as a pull request,
# please first remove this boilerplate and all FIXME comments.
#
# This is a template package file for Spack.  We've put "FIXME"
# next to all the things you'll want to change. Once you've handled
# them, you can save this file and test your package like this:
#
#     spack install py-pydata-sphinx-theme
#
# You can edit this file again by typing:
#
#     spack edit py-pydata-sphinx-theme
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from importlib import import_module

pydata_sphinx_theme = import_module("spack.pkg.builtin.py-pydata-sphinx-theme")

class PyPydataSphinxTheme(pydata_sphinx_theme.PyPydataSphinxTheme):

    version("0.16.1", sha256="a08b7f0b7f70387219dc659bff0893a7554d5eb39b59d3b8ef37b8401b7642d7")

    depends_on("python@3.8:", type=("build", "run"))

    depends_on("py-sphinx-theme-builder", type="build")

    depends_on("py-sphinx@5:", type=("build", "run"))
    depends_on("py-beautifulsoup4", type=("build", "run"))
    depends_on("py-docutils@:0.16,0.17.1:", type=("build", "run"))
    depends_on("py-packaging", type=("build", "run"))
    depends_on("py-babel", type=("build", "run"))
    depends_on("py-pygments@2.7:", type=("build", "run"))
    depends_on("py-accessible-pygments", type=("build", "run"))
    depends_on("py-typing-extensions", type=("build", "run"))    
    
