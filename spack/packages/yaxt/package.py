from spack.package import *

class Yaxt(AutotoolsPackage):
    """
    Yet another exchange tool

    License: MIT
    """
    homepage = "https://swprojects.dkrz.de/redmine/projects/yaxt"

    maintainers = ['scottwales']

    version('0.11.3','1dde53de4805b3fb32256d61c9c18b937252345009ff82db3ad78c322181f5a7',url="https://swprojects.dkrz.de/redmine/attachments/download/541/yaxt-0.11.3.tar.gz")
    version('0.9.3.1','5cc2ffeedf1604f825f22867753b637d41507941b7a0fbbfa6ea40637a77605a',url="https://swprojects.dkrz.de/redmine/attachments/download/523/yaxt-0.9.3.1.tar.gz")
    version('0.9.0', 'd3673e88c1cba3b77e0821393b94b5952d8ed7dc494305c8cf93e7ebec19483c', url='https://swprojects.dkrz.de/redmine/attachments/download/498/yaxt-0.9.0.tar.gz')

    depends_on('mpi')
    variant('idxtype', default='int', values=('int','long'), multi=False)

    def setup_build_environment(self, env):
        env.set('CC', self.spec['mpi'].mpicc)
        env.set('CXX', self.spec['mpi'].mpicxx)
        env.set('F77', self.spec['mpi'].mpif77)
        env.set('FC', self.spec['mpi'].mpifc)

        env.set('CFLAGS', '-g')
        env.set('FCFLAGS', '-g')

        if 'intel-oneapi-mpi' in self.spec:
            env.prepend_path('PATH', self.spec['intel-oneapi-mpi'].package.component_prefix.bin)
            env.unset('I_MPI_ROOT')

    def configure_args(self):
        options = []
        options.append('--with-idxtype='+self.spec.variants['idxtype'].value)

        # Ignore MPI errors on build machine
        options.append('--without-regard-for-quality')

        return options
