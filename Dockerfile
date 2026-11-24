# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS toolchain

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    libgtest-dev \
    libpcre3-dev \
    libtool \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src

FROM toolchain AS builder

COPY . .

RUN mkdir -p m4 \
  && autoreconf --install \
  && mkdir -p build \
  && cd build \
  && ../configure \
  && make -j"$(nproc)" \
  && ./src/annabell test \
  && make install

FROM builder AS dev

RUN apt-get update && apt-get install -y --no-install-recommends \
    gdb \
    git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
CMD ["/bin/bash"]

FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    libpcre3 \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd --gid 1000 annabell \
  && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash annabell \
  && mkdir -p /work \
  && chown annabell:annabell /work

COPY --from=builder /usr/local/bin/annabell /usr/local/bin/annabell

WORKDIR /work
USER annabell

ENTRYPOINT ["annabell"]
