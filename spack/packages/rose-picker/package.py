# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import PythonPackage
from llnl.util.filesystem import install_tree


class RosePicker(PythonPackage):

    """rose_picker - utility for LFRIC."""

    homepage = "https://code.metoffice.gov.uk/svn/lfric/GPL-utilities"
    svn = f"{homepage}/trunk"

    version("2.0.0", svn=f"{homepage}/tags/v2.0.0")
    version("r31715", revision=31715)
    version("1.0.0", svn=f"{homepage}/tags/v1.0.0")

    extends("python@3:")

    def install(self, spec, prefix):
        install_tree(src=".", dest=prefix, symlinks=True, ignore=None)

    def setup_run_environment(self, env):

        env.prepend_path("PYTHONPATH", self.spec.prefix.lib.python)
