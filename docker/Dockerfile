# syntax=docker/dockerfile:1

FROM ubuntu:latest as base

FROM base as build

RUN echo "Setting up dependencies..." && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        g++ \
        cmake \
        libpcre3-dev \
        libgtest-dev \
        make \
        pkg-config \
    	xz-utils && \
    cd /usr/src/gtest && \
    cmake CMakeLists.txt && \
    make && \
    rm -rf /var/lib/apt/lists/*

COPY annabell.tar.xz /app/

RUN echo "Setting up Annabell..." && \
    cd /app/ && \
    tar -xvJf annabell.tar.xz && \
    echo "Contents of /app after tar:" && \
    ls -l /app/ && \
    # Assuming tar extracts to a directory named 'annabell' inside /app
    cd annabell && \
    ./configure && \
    make && \
    make install

FROM base AS final

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        adduser \
        libpcre3 \
        libgomp1 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/annabell /usr/local/bin/annabell

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser
USER appuser

ENTRYPOINT [ "annabell" ]