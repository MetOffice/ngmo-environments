# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import PythonPackage


class Mule(PythonPackage):

    """Mule - UM files API.

    Mule is an API written in Python which allows you to access and
    manipulate files produced by the Unified Model.
    """

    homepage = "https://code.metoffice.gov.uk"
    url = "https://github.com/metomi/mule/archive/refs/tags/2022.05.1.tar.gz"
    build_directory = "mule"

    version(
        "2022.05.1",
        sha256="c93caefa48fe981baf8f8e021673748ddf0eda4216d8700fce4fd39d024c17e4",
    )

    variant("sstpert", default=True, description="build SST perturbation support")
    variant("wafccb", default=True, description="build WAFC CB support")
    variant("openmp", default=False, description="enable OpenMP support")

    # FIXME: Add openmp and sequential variants with matching shumlib
    # dependencies

    depends_on("shumlib", when="-openmp")
    depends_on("shumlib+openmp", when="+openmp")

    depends_on("python@:3.9.17")
    depends_on("py-numpy")
    depends_on("py-setuptools")
    depends_on("py-six")
    depends_on("py-um-packing")
    depends_on("py-um-ppibm")
    depends_on("py-um-spiral-search")
    depends_on("py-um-utils")

    # FIXME: deal with external dependencies as well as APIs
    # depends_on("py-um-sstpert", when="+sstpert")
    # depends_on("py-um-wafccb", when="+wafccb")

    @run_before("build")
    def update_directory(self):

        """Reset the location of the build directory."""

        build_directory = f"mule-{self.version}/{build_directory}"

    # FIXME: Tests currently fail at Python 3.10 with the error:
    #   SystemError: PY_SSIZE_T_CLEAN macro must be defined for '#' formats
    # The python documentation implies this is an intentional feature change:
    #   https://docs.python.org/3/c-api/arg.html#strings-and-buffers
    # This needs fixing at some point but the current workaround is use an
    # earlier version of python where the error is only deprecation warning
    @run_after("install")
    @on_package_attributes(run_tests=True)
    def install_test(self):

        """Run the post-installation unit tests."""

        with working_dir("spack-test", create=True):
            python("-m", "unittest", "discover", "-v", "mule.tests")
