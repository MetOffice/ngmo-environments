# Copyright 2013-2024 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class Blitz(AutotoolsPackage):
    """N-dimensional arrays for C++"""

    homepage = "https://github.com/blitzpp/blitz"
    url = "https://github.com/blitzpp/blitz/archive/1.0.2.tar.gz"

    license("LGPL-3.0-only")

    version("1.0.2", sha256="500db9c3b2617e1f03d0e548977aec10d36811ba1c43bb5ef250c0e3853ae1c2")

    depends_on("python@3:", type="build")
    depends_on("m4", type="build")
    depends_on("autoconf", type="build")
    depends_on("automake", type="build")
    depends_on("libtool", type="build")

    # Fix makefile and include to build with Fujitsu compiler
    patch("fujitsu_compiler_specfic_header.patch", when="%fj")
    patch("llvm_compiler_specific_header.patch", when="%cce")
    patch("llvm_compiler_specific_header.patch", when="%oneapi")

    build_targets = ["lib"]

    force_autoreconf = True
    autoreconf_extra_args = ["--install"]

    @run_before("autoreconf")
    def remove_symlinks(self):
        """
        Remove included symlinks to /usr/share/aclocal, autoreconf will set up
        corrected links
        """
        with working_dir(self.stage.source_path):
            rm = which("rm")
            rm("m4/libtool.m4")
            rm("m4/ltoptions.m4")
            rm("m4/ltsugar.m4")
            rm("m4/ltversion.m4")
            rm("m4/lt~obsolete.m4")

    def setup_build_environment(self, env):
        if self.spec.satisfies("%cce") or self.spec.satisfies("%oneapi"):
            env.set("COMPILER_SPECIFIC_HEADER", "llvm/bzconfig.h")

    def check(self):
        make("check-testsuite")
        make("check-examples")
