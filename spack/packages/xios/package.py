# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.pkg.builtin.xios import Xios as BaseXios
from llnl.util import tty
import os


class Xios(BaseXios):
    """Extension of builtin XIOS package."""

    # LFRic requires the following:
    # https://forge.ipsl.fr/ioserver/svan/XIOS/trunk revision=2252
    # https://forge.ipsl.fr/ioserver/browser/XIOS2

    version("develop", svn="https://forge.ipsl.fr/ioserver/svn/XIOS2/trunk")
    version("2252", revision=2252, svn="https://forge.ipsl.fr/ioserver/svn/XIOS2/trunk")
    version("2663", revision=2663, svn="https://forge.ipsl.fr/ioserver/svn/XIOS2/trunk")
    version("2701", revision=2701, svn="https://forge.ipsl.fr/ioserver/svn/XIOS2/trunk")

    variant("oasis", default=False, description="enable OASIS support")

    depends_on("blitz")
    depends_on("subversion", type="build")
    depends_on("oasis", type="build", when="+oasis")

    #patch("mesh_cpp.patch", when="%intel")
    patch("lfric_xios2.2629.patch", when="%intel")

    def patch(self):

        """Patch GCC 12 header problems.

        With GCC 12, some lesser-used C++ header files are no longer
        included by default.  This causes XIOS to fail to build and
        the following patches the missing array header files back in.

        These changes were adopted by XIOS at r2701, so are only applicable
        to older revisions of XIOS.
        """

        if (self.spec.satisfies("%gcc@12:") and
                self.spec.satisfies("@2252:2700")):
            # Only patch for GCC 12 and above and XIOS r2252 : r2700
            # Note that the replacements are not r-strings because they
            # need to contain newlines
            filter_file(
                r"^(#include\s*<vector>\s*)$",
                "#include <array>\n\\1",
                "src/xios_spl.hpp",
                backup=True,
            )

            filter_file(
                r"^(#include\s*<list>\s*)$",
                "#include <array>\n\\1",
                "extern/remap/src/elt.hpp",
                backup=True,
            )

            if self.spec.satisfies("@2663:"):
                # Needed at 2663 with GCC 12
                filter_file(
                    r"^(#include\s*<limits.h>\s*)$",
                    "#include <cfloat>\n\\1",
                    "src/io/nc4_data_output.cpp",
                    backup=True,
                )

        return

    def xios_fcm(self):

        """Create an fcm configuration for the current system.

        Override the method in the base package to create a modified
        fcm configuration for the latest releases of XIOS.  Fixes
        include the addition of the -lstdc++ flag and a flag to
        support long source lines in gfortran.
        """

        file = join_path("arch", "arch-SPACK.fcm")
        spec = self.spec
        param = dict()
        param["MPICXX"] = spec["mpi"].mpicxx
        param["MPIFC"] = spec["mpi"].mpifc
        param["CC"] = self.compiler.cc
        param["FC"] = self.compiler.fc
        param["BOOST_INC_DIR"] = spec["boost"].prefix.include
        param["BOOST_LIB_DIR"] = spec["boost"].prefix.lib
        param["BLITZ_INC_DIR"] = spec["blitz"].prefix.include
        param["BLITZ_LIB_DIR"] = spec["blitz"].prefix.lib
        if spec.satisfies("%apple-clang"):
            param["LIBCXX"] = "-lc++"
        else:
            param["LIBCXX"] = "-lstdc++"

        if spec.satisfies("%gcc"):
            # Allow long lines in gfortran
            param["FFLAGS"] = "-ffree-line-length-none"
            param['BACKTRACE'] = '-fbacktrace'
        else:
            param["FFLAGS"] = ""
            param['BACKTRACE'] = '-traceback'

        # Note: removed "%intel", "%apple-clang", "%clang", "%fj" from
        # the list on the assumption that the flags will need changing
        # to work with these compilers
        if any(map(spec.satisfies, ("%gcc", "%cce", "%intel", "%oneapi"))):
            text = r"""
%CCOMPILER      {MPICXX}
%FCOMPILER      {MPIFC}
%LINKER         {MPIFC}

%BASE_CFLAGS    -ansi -w -D_GLIBCXX_USE_CXX11_ABI=0 \
                -I{BOOST_INC_DIR} -I{BLITZ_INC_DIR} -std=c++11
%PROD_CFLAGS    -O3 -DBOOST_DISABLE_ASSERTS
%DEV_CFLAGS     -g -O2
%DEBUG_CFLAGS   -g

%BASE_FFLAGS    -D__NONE__ {FFLAGS}
%PROD_FFLAGS    -O3
%DEV_FFLAGS     -g {BACKTRACE} -O2
%DEBUG_FFLAGS   -g {BACKTRACE}

%BASE_INC       -D__NONE__
%BASE_LD        -L{BOOST_LIB_DIR} -L{BLITZ_LIB_DIR} -lblitz {LIBCXX}

%CPP            {CC} -E
%FPP            {CC} -E -P -x c
%MAKE           gmake
""".format(
                **param
            )

        else:
            raise InstallError("Unsupported compiler.")

        with open(file, "w") as f:
            f.write(text)

    def install(self, spec, prefix):
        """Replacement install method."""

        env["CC"] = spec["mpi"].mpicc
        env["CXX"] = spec["mpi"].mpicxx
        env["F77"] = spec["mpi"].mpif77
        env["FC"] = spec["mpi"].mpifc

        options = [
            "--full",
            "--%s" % spec.variants["mode"].value,
            "--arch",
            "SPACK",
            "--netcdf_lib",
            "netcdf4_par",
            "--use_extern_boost",
            "--use_extern_blitz",
            "--job",
            str(make_jobs),
        ]

        if "%cce" in self.spec:
            # Parallel builds do not work with CCE, so disable them
            tty.warn("restricted to serial builds with Cray compiler")
            options[-1] = "1"

        if "+oasis" in self.spec:
            # Add OASIS build flag
            options += ["--use_oasis", "oasis3_mct"]

            # Save OASIS flags for later use
            self.oasis_incdir = join_path(self.spec["oasis"].prefix, "include")
            self.oasis_libdir = join_path(self.spec["oasis"].prefix, "lib")
            self.oasis_lflags = "-lpsmile.MPI1 -lscrip -lmct -lmpeu"

        else:
            self.oasis_incdir = None
            self.oasis_libdir = None
            self.oasis_lflags = None

        self.xios_env()
        self.xios_path()
        self.xios_fcm()

        make_xios = Executable("./make_xios")
        make_xios(*options)

        mkdirp(spec.prefix)
        install_tree("bin", spec.prefix.bin)
        install_tree("lib", spec.prefix.lib)
        install_tree("inc", spec.prefix.include)
        install_tree("etc", spec.prefix.etc)
        install_tree("cfg", spec.prefix.cfg)

    def xios_env(self):
        """Create XIOS environment file.

        The parent method creates an empty file.  Overload this to add
        OASIS environment variables if necessary.
        """

        # This creates an empty environment file
        super().xios_env()

        if "-oasis" in self.spec:
            # Do nothing if OASIS is not enabled
            return

        # Add OASIS compiler settings to the env file
        with open(join_path("arch", "arch-SPACK.env"), "w") as f:
            print(f'export OASIS_INCDIR="-I{self.oasis_incdir}"', file=f)
            print(f'export OASIS_LIBDIR="-L{self.oasis_libdir}"', file=f)
            print(f'export OASIS_LIB="{self.oasis_lflags}"', file=f)

    def xios_path(self):
        """Create XIOS path file.

        The parent method sets a number of variable but leaves the
        OASIS settings empty.  Overload this use filter_file with a
        custom replacement function to set the various OASIS flags
        based on attribute values set in install().
        """

        # This creates the file with its default values
        super().xios_path()

        if "-oasis" in self.spec:
            # Do nothing if OASIS is not enabled
            return

        def replacer(match):
            """Add the correct OASIS flags"""
            if match.group(1).endswith("INCDIR"):
                setting = f"-I{self.oasis_incdir}"
            elif match.group(1).endswith("LIBDIR"):
                setting = f"-L{self.oasis_libdir}"
            elif match.group(1).endswith("LIB"):
                setting = self.oasis_lflags
            return f'{match.group(1)}="{setting}"'

        # Use spack's filter_file with a custom replacement function
        # to change all the OASIS flags in a single operation
        filter_file(
            r"^\s*(OASIS_[^=]+)=.*",
            replacer,
            join_path("arch", "arch-SPACK.path"),
            backup=True,
        )

    @run_after("install")
    def remove_fcm_env(self):
        """Remove broken fcm_env.ksh symlink."""
        target = os.path.join(self.spec.prefix.bin, "fcm_env.ksh")
        if os.path.islink(target):
            os.unlink(target)

    def setup_run_environment(self, env):

        """Setup custom variables in the generated module file"""

        env.prepend_path("FFLAGS", "-I" + self.spec.prefix.include, " ")
        env.prepend_path("CPPFLAGS", "-I" + self.spec.prefix.include, " ")
        env.prepend_path("LDFLAGS", "-L" + self.spec.prefix.lib + " -Wl,-rpath=" + self.spec.prefix.lib, " ")
