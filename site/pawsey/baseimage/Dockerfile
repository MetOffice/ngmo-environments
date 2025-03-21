FROM opensuse/leap:15

RUN zypper --non-interactive install \
             bzip2 \
             curl \
             diffutils \
             file \
             findutils \
             gcc \
             gcc-c++ \
             git \
             gzip \
             libatomic1 \
             libtool \
             lua53 \
             make \
             openssl \
             patch \
             subversion \
             tar \
             time \
             unzip \
             wget \
             which \
             xz \
             xz-devel \
             zstd

ENTRYPOINT ["/ngmo/bin/entrypoint.sh"]
