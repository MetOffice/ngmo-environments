class Shumlib(MakefilePackage):
    homepage = "https://code.metoffice.gov.uk/trac/utils/wiki/shumlib"
    parallel = False

    url = "https://github.com/metomi/shumlib/archive/refs/tags/um13.0.tar.gz"

    version(
        "um13.0",
        sha256="50f43a2f8980e8fbeafd053376612503bcb17c34948297f19b2c95ce0642b340",
        url="https://github.com/metomi/shumlib/archive/refs/tags/um13.0.tar.gz",
    )

    def edit(self, spec, prefix):
        env["PLATFORM"] = "spack"
        env["FPP"] = "cpp"
        env[
            "FPPFLAGS"
        ] = "-C -P -undef -nostdinc -DEVAL_NAN_BY_BITS -DEVAL_DENORMAL_BY_BITS"
        env["FCFLAGS_OPENMP"] = "-fopenmp"
        env["FCFLAGS_PIC"] = "-fPIC"
        env["FCFLAGS_SHARED"] = "-shared"
        env["CCFLAGS_OPENMP"] = "-fopenmp"
        env["CCFLAGS_PIC"] = "-fPIC"
        env["AR"] = "ar -rc"

        env["DIR_ROOT"] = self.stage.source_path
        env["LIBDIR_OUT"] = prefix
        env["SHUM_USE_C_OPENMP_VIA_THREAD_UTILS"] = "false"

    def install(self, spec, prefix):
        pass
