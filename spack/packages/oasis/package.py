# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


import os
from spack.package import MakefilePackage
from llnl.util.filesystem import install_tree


class Oasis(MakefilePackage):
    """OASIS coupler"""

    version("3-mct5.0", branch="OASIS3-MCT_5.0", git="https://gitlab.com/cerfacs/oasis3-mct.git")

    depends_on("netcdf-fortran")
    depends_on("mpi")
    depends_on("gmake")

    variant("mct", default=True, description="enable Model Coupling Toolkit")
    variant(
        "channel",
        default="mpi1",
        description="communication channel",
        values=("mpi1", "mpi2"),
    )

    # There appears to be a race condition in the makefile when the
    # number of cores is large, so disable parallel builds
    parallel = False

    # Directory containing the Makefile - used by the superclass
    build_directory = "util/make_dir"

    # Name of the spack install target
    arch_target = "spack_oasis3-mct"

    def edit(self, spec, prefix):
        """Create a spack configuration file."""

        # Set the working directory location and the directory
        # containing the Makefiles
        working = os.getcwd()
        make_dir = os.path.join(working, self.build_directory)

        self.arch_directory = os.path.join(working, self.arch_target)

        netcdff_inc = spec["netcdf-fortran"].prefix.include
        netcdff_lib = spec["netcdf-fortran"].prefix.lib

        cppflags = "-Duse_libMPI -Duse_netCDF -Duse_comm_$(CHAN) -DDEBUG"
        cflags = cppflags

        # Always include netCDF fortran flags and C preprocessor flags
        fflags = f"-I{netcdff_inc} {cppflags}"
        ldflags = ""

        if self.spec.satisfies("%cce"):
            # Cray compiler flags
            fflags += f" -e m -s real64 -O2 {cppflags}"
            ldflags += " -h byteswapio"
        elif self.spec.satisfies("%gcc"):
            # GCC compiler flags
            fflags += " -fallow-argument-mismatch -ffree-line-length-none"

        cflags += " $(PSMILE_INCDIR)"
        fflags += " $(INCPSMILE)"

        params = {
            # Communication technique used in OASIS3 (MPI1/MPI2)
            "CHAN": self.spec.variants["channel"].value.upper(),
            # Path for oasis3-mct main directory
            "COUPLE": working,
            # Directory created when compiling
            "ARCHDIR": self.arch_directory,
            # MPI commands can be ignored - only used by pyoasis?
            # NetCDF
            "NETCDF_INCLUDE": f"-I{netcdff_inc}",
            "NETCDF_LIBRARY": f"-L{netcdff_lib} -lnetcdff",
            # Tools
            "MAKE": os.path.join(spec["gmake"].prefix.bin, "gmake"),
            "AR": "ar",
            "ARFLAGS": "-ruv",
            # Compilers are set above
            "F90": spec["mpi"].mpifc,
            "F": spec["mpi"].mpifc,
            "f90": spec["mpi"].mpifc,
            "f": spec["mpi"].mpifc,
            "CC": spec["mpi"].mpicc,
            "LD": spec["mpi"].mpifc,
            # Flags and switches
            "CPPDEF": cppflags,
            "CCPPDEF": cppflags,
            "CCFLAGS": cflags,
            "F90FLAGS": fflags,
            "f90FLAGS": fflags,
            "FFLAGS": fflags,
            "fFLAGS": fflags,
            "LDFLAGS": ldflags,
            # The following shouldn't change
            "FLIBS": "$(NETCDF_LIBRARY)",
            "BINDIR": "$(ARCHDIR)/bin",
            "LIBBUILD": "$(ARCHDIR)/build/lib",
        }

        # Write the macro settings to an include file
        with open(f"{make_dir}/make.spack", "w", encoding="utf-8") as fd:
            for key, value in params.items():
                print(f"{key} = {value}", file=fd)

        # Set the main inc file to pick up make.spack
        with open(f"{make_dir}/make.inc", "w", encoding="utf-8") as fd:
            print(f"include {make_dir}/make.spack", file=fd)

        # Link the Makefile to the OASIS make file to remove the need
        # to override the superclass build function
        os.symlink(f"{make_dir}/TopMakefileOasis3", f"{make_dir}/Makefile")

        return

    def install(self, spec, prefix):
        """Install the include files and libraries.

        The OASIS make system does not include an install target, so
        this function carries it out instead.
        """

        copy_tree(
            os.path.join(self.arch_directory, "include"), self.spec.prefix.include
        )

        copy_tree(os.path.join(self.arch_directory, "lib"), self.spec.prefix.lib)

        return

    def setup_run_environment(self, env):
        """Setup custom variables in the generated module file"""

        env.prepend_path("FFLAGS", "-I" + self.spec.prefix.include, " ")
        env.prepend_path("CPPFLAGS", "-I" + self.spec.prefix.include, " ")
        env.prepend_path("LDFLAGS", "-L" + self.spec.prefix.lib, " ")
