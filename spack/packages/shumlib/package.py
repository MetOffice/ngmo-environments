# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import os
import shutil
from spack.package import MakefilePackage


class Shumlib(MakefilePackage):

    """Shared UM Library.

    Shumlib is the collective name for a set of libraries which are
    used by the UM; the UK Met Office's Unified Model, that may be of
    use to external tools or applications where identical
    functionality is desired. The hope of the project is to enable
    developers to quickly and easily access parts of the UM code that
    are commonly duplicated elsewhere, at the same time benefiting
    from any improvements or optimisations that might be made in
    support of the UM itself.
    """

    homepage = "https://code.metoffice.gov.uk"
    url = "https://github.com/metomi/shumlib/archive/refs/tags/um13.0.tar.gz"

    # shumlib does not currently build in parallel
    parallel = False

    version(
        "13.0",
        sha256="50f43a2f8980e8fbeafd053376612503bcb17c34948297f19b2c95ce0642b340",
    )

    variant("openmp", default=False, description="enable OpenMP support")

    def edit(self, spec, prefix):

        """Minor setup edits."""

        # Create a copy the makefile
        source = "make/vm-x86-gfortran-gcc.mk"
        self.dest = "make/spack.mk"
        shutil.copy(source, self.dest)

        # FIXME: set a better identifier
        makefile = FileFilter(self.dest)
        makefile.filter(r"^\s*PLATFORM\s*=.*", "PLATFORM=spack-fortran-cc")

        if "+openmp" not in self.spec:
            # Ensure openmp is switched off
            makefile.filter(r"^\s*FCFLAGS_OPENMP\s*=.*", "FCFLAGS_OPENMP=")
            makefile.filter(r"^\s*CCFLAGS_OPENMP\s*=.*", "CCFLAGS_OPENMP=")

    def build(self, *args, **kwargs):

        super().build(*args, **kwargs)

    def install(self, spec, prefix):

        mkdir(prefix.lib)
        install_tree("build/spack-fortran-cc/lib", prefix.lib)
        mkdir(prefix.include)
        install_tree("build/spack-fortran-cc/include", prefix.include)

    @property
    def build_targets(self):

        current = os.getcwd()

        args = ["-f", self.dest, f"DIR_ROOT={current}", f"LIBDIR_ROOT={current}/build"]

        if "+openmp" in self.spec:
            # args.append("SHUM_USE_C_OPENMP_VIA_THREAD_UTILS=true")
            env["SHUM_USE_C_OPENMP_VIA_THREAD_UTILS"] = "true"

            # FIXME: not sure about this!
            env["LIBDIR_OUT"] = self.prefix.lib

        return args

    def setup_run_environment(self, env):
        """Setup custom variables in the generated module file"""

        env.prepend_path("FFLAGS", "-I" + self.spec.prefix.include, " ")
        env.prepend_path("CPPFLAGS", "-I" + self.spec.prefix.include, " ")
        env.prepend_path("LDFLAGS", "-L" + self.spec.prefix.lib + " -Wl,-rpath=" + self.spec.prefix.lib, " ")
