# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import shutil
from spack.package import PythonPackage


class PyUmWafccb(PythonPackage):

    """Unified Model WAFC CB interface.

    This um_wafccb module provides a Python extension from the UM WAFC
    CB library.  Note that the UM WAFC CB library itself is obtainable
    via a UM licence and must be installed separately.
    """

    homepage = "https://code.metoffice.gov.uk"
    url = "https://code.metoffice.gov.uk/svn/um/mule/trunk"
    build_directory = "um_wafccb"

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
