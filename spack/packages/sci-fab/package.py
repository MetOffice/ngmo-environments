# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import PythonPackage


class SciFab(PythonPackage):

    """Fab - A Build System for Tomorrow!

    The Fab build system aims to provide a quick and easy build
    process tailored towards a specific subset of scientific software
    developers. Quick should be in both use and operation. Easy should
    mean the simple things are simple and the complicated things
    possible.
    """

    homepage = "https://github.com/metomi/fab"
    pypi = "sci-fab/sci_fab-0.10.1-py3-none-any.whl"

    version(
        "0.10.1",
        sha256="9c8128e8f6dda950ca8fd748523af9d3805d6b2d27e1f8096927dcda37123ab3",
        expand=False,
        deprecated=True,
    )

    version(
        "1.0",
        sha256="4321a826223895602f52d79bea5848fd779dd54c2bd9f97634309847cbc42620",
        expand=False,
    )

    depends_on("python@3.7:")
    depends_on("py-fparser")
    depends_on("py-libclang")
