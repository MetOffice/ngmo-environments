# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import shutil
from spack.package import PythonPackage


class PyUmSstpert(PythonPackage):

    """Unified Model SST perturbation.

    This um_sstpert module provides a Python extension from the UM
    sstpert library, and an associated utility to produce SST
    perturbation files.
    """

    homepage = "https://code.metoffice.gov.uk"
    url = "https://code.metoffice.gov.uk/svn/um/mule/trunk"
    build_directory = "um_sstpert"

    version(
        "115247",
        sha256="c4c54a10c700bd174dbd7d5f7d2822c628a9f1d24961c51bac3d8e0868781d45",
    )

    depends_on("shumlib")
    depends_on("python@3:")
    depends_on("py-numpy")
    depends_on("py-six")

    def url_for_version(self, version):

        """Fake download method."""

        return f"file:///cray_home/mo-itsa/Programs/mule-{version}.tar.gz"
