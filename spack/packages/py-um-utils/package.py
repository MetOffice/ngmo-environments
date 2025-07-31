# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import shutil
from spack.package import PythonPackage


class PyUmUtils(PythonPackage):

    """Unified Model file utilities.

    This um_utils module provides a series of specific utility tools
    for working with UM files.  Most of these tools can be used via a
    series of command-line scripts, or imported and used in python.
    """

    homepage = "https://code.metoffice.gov.uk"
    url = "https://github.com/metomi/mule/archive/refs/tags/2022.05.1.tar.gz"
    build_directory = "um_utils"

    version(
        "2022.05.1",
        sha256="c93caefa48fe981baf8f8e021673748ddf0eda4216d8700fce4fd39d024c17e4",
    )

    depends_on("shumlib")
    depends_on("python@3:")
    depends_on("py-numpy")
    depends_on("py-six")

    @run_before("build")
    def update_directory(self):

        """Update the location of the build directory."""

        build_directory = f"mule-{self.version}/{build_directory}"
