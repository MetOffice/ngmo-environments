# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import PythonPackage


class PyConfigurableHttpProxy(PythonPackage):

    """Python implementation of configurable-http-proxy.

    This is a pure python implementation of the
    configurable-http-proxy written in nodejs. It is meant to be a
    drop in replacement.
    """

    homepage = "https://github.com/corridor/configurable-http-proxy"
    pypi = "configurable-http-proxy/configurable-http-proxy-0.2.3.tar.gz"

    version(
        "0.2.3",
        sha256="73147aefbcb25c2ab5b884314185998dc8933a134d8b5b43375a79f0aa383dab",
    )

    depends_on("python@3.6:")
    depends_on("py-setuptools", type="build")
