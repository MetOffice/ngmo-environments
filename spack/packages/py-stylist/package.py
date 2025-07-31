# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import PythonPackage


class PyStylist(PythonPackage):

    """Stylist - a code style checking tool.

    It is built on a framework which supports multiple styles across
    multiple languages, including Fortran.
    """

    homepage = "https://github.com/MetOffice/stylist"
    pypi = "stylist/stylist-0.2.tar.gz"
    
    version("0.4.1", sha256="3f48ac66f1f8a3d884f3fd923fbae92a5855e2bc7b858131a5788de73f195005")
    version("0.2", sha256="581bb33a86d7637cb54fcd8b3c572e52397d0dcb60d3c5fdb48755a6d88e566d")

    depends_on("python@3.7:")
    depends_on("py-fparser@0.0.12:", when="@0.2")
    depends_on("py-fparser@0.1.2:", when="@0.4.1")
    depends_on("py-setuptools", type="build")
