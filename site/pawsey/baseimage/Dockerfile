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
