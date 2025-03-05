FROM rockylinux:8-minimal

RUN microdnf install -y --nodocs \
             bzip2 \
             bzip2-devel \
             curl \
             diffutils \
             file \
             findutils \
             gcc \
             gcc-c++ \
             gcc-gfortran \
             git \
             gzip \
             libatomic \
             libtool \
             make \
             openssl \
             openssl-devel \
             patch \
             pinentry-curses \
             subversion \
             tar \
             time \
             unzip \
             wget \
             which \
             xz \
             xz-devel \
             zstd \
        && microdnf clean all

ENTRYPOINT ["/ngmo/bin/entrypoint.sh"]
