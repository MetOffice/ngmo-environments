# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import PythonPackage


class PySphinxSitemap(PythonPackage):

    """A Sphinx extension to generate multiversion and multilanguage sitemaps.org 
       compliant sitemaps for the HTML version of your Sphinx documentation
    """

    homepage = "https://github.com/jdillard/sphinx-sitemap"
    pypi = "sphinx-sitemap/sphinx_sitemap-2.6.0.tar.gz"
    license("MIT")

    version(
        "2.6.0", sha256="5e0c66b9f2e371ede80c659866a9eaad337d46ab02802f9c7e5f7bc5893c28d2"
    )

    depends_on("python@3.8:", when="@2.6.0")
    depends_on("py-six")
    depends_on("py-sphinx@1.2:", when="@2.6.0")
