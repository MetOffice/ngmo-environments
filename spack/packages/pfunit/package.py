# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.pkg.builtin.pfunit import Pfunit as BasePfunit
import os

class Pfunit(BasePfunit):

    def setup_run_environment(self, env):
        """Setup custom variables in the generated module file"""
        major_version, minor_version, _ = str(self.spec.version).split(".")
        prefix_subdir = os.path.join(
                self.spec.prefix,
                str(self.spec.name).upper() + "-" + major_version + "." + minor_version
                )
        env.prepend_path("FFLAGS", "-I" + os.path.join(prefix_subdir, "include"), " ")
        env.prepend_path("CPPFLAGS", "-I" + os.path.join(prefix_subdir, "include"), " ")
        env.prepend_path("LDFLAGS", "-L" + os.path.join(prefix_subdir, "lib") + " -Wl,-rpath=" + os.path.join(prefix_subdir, "lib"), " ")
        env.set("PFUNIT", prefix_subdir)
