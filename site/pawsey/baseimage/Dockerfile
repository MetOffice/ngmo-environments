FROM opensuse/leap:15

# Setup default linker search paths
COPY pawsey-ld.conf /etc/ld.so.conf.d/pawsey-ld.conf

RUN zypper --non-interactive install \
             bzip2 \
             curl \
             diffutils \
             file \
             findutils \
             gcc \
             gcc-c++ \
             gcc-fortran \
             git \
             gzip \
             libatomic1 \
             libtool \
             libgfortran5 \
             lua53 \
             lua53-luaposix \
             lua53-luasocket \
             make \
             openssl \
             patch \
             subversion \
             tar \
             tcl \
             time \
             unzip \
             wget \
             which \
             xz \
             xz-devel \
             zstd \
    && zypper clean

ENTRYPOINT ["/ngmo/bin/entrypoint.sh"]
