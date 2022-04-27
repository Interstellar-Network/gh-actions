################################################################################

# podman build -f build_ccache.dockerfile -t ccache:dev .
# [TEST] podman run --rm -it ccache:dev /bin/bash
# podman create --name ccache_dev ccache:dev
# podman cp ccache_dev:/usr/local/bin/ccache bin/ccache
# podman rm ccache_dev
# Then create a GH Release with tag eg "ccache-4.6"
# then in action.yml you can eg "wget https://github.com/Interstellar-Network/gh-actions/releases/download/ccache-4.6/ccache"

FROM ubuntu:20.04 as builder

WORKDIR /usr/src/app

# DEBIAN_FRONTEND needed to stop prompt for timezone
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    wget build-essential cmake \
    && rm -rf /var/lib/apt/lists/*

# --strip-components 1: allows to decompress directly in the cwd instead of eg "ccache-4.6/"
RUN wget -c https://github.com/ccache/ccache/releases/download/v4.6/ccache-4.6.tar.gz -O - | tar -xz --strip-components 1 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DZSTD_FROM_INTERNET=ON -DREDIS_STORAGE_BACKEND=OFF -DENABLE_TESTING=OFF .. && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf *

ENTRYPOINT  ["/usr/local/bin/ccache"]