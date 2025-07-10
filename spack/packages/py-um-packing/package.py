# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import shutil
from spack.package import PythonPackage


class PyUmPacking(PythonPackage):

    """Unified Model packing.

    This um_packing module provides a Python extension from the SHUMlib packing
    library, which Mule can optionally make use of.
    """

    homepage = "https://code.metoffice.gov.uk"
    url = "https://github.com/metomi/mule/archive/refs/tags/2022.05.1.tar.gz"
    build_directory = "um_packing"

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

        """Reset the location of the build directory."""

        build_directory = f"mule-{self.version}/{build_directory}"
