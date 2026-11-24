Annabell
========

A cognitive neural architecture able to learn and communicate through natural language.

Installation and usage
----------------------

**Note:** For an easy way of setting up a development environment for annabell using **Vagrant**, please refer to [this instructions](vagrant/Vagrant.md).

In order to build the project the following libraries are needed:

 - **pthread** and **gtest**: [Download from GoogleTest project](https://github.com/google/googletest)
 - **pcre**: [Download from pcre.org](http://pcre.org/)

Additionally, installation and usage instructions are provided in the document **annabell-x.x.x_man.pdf**, where x.x.x refers to the version number.

Building from source
--------------------

This project uses GNU Autotools (http://www.gnu.org/software/automake/manual/html_node/Autotools-Introduction.html#Autotools-Introduction).

The recommended way of building from source is as follows:

 - run `autoreconf --install` from root directory
 - `mkdir build`
 - `cd build`
 - `../configure`
 - `make`

That will configure `build` subdirectory to build the project, avoiding clutter on the root directory and generating all .o and binaries there. In particular it will generate the `annabell` program in `build/src/annabell`

Using Docker
------------

This repository includes a multi-stage `Dockerfile` (based on `debian:bookworm-slim`, built with OpenMP) and `compose.yaml`.

### Build the runtime image

```bash
docker build -t annabell .
```

The build compiles `annabell` and runs the built-in unit tests (`annabell test`) automatically so broken builds fail fast.

### Run the runtime container

The default image has `ENTRYPOINT ["annabell"]`, sets `/work` as its working directory, and runs as a non-root user `annabell` (UID/GID `1000`).

- Start an interactive session:

```bash
docker run --rm -it annabell
```

- Mount the current directory into `/work` to load local files (e.g., `.f simple_examples/example1.txt`):

```bash
docker run --rm -it -v "$PWD:/work" annabell
```

- Pipe a command script non-interactively:

```bash
(echo ".f simple_examples/example1.txt"; echo ".q") | docker run --rm -i -v "$PWD:/work:ro" annabell
```

- Pass command-line flags such as `-pf`:

```bash
docker run --rm -it -v "$PWD:/work" annabell -pf simple_examples/params.txt
```

- Run the built-in GoogleTest suite:

```bash
docker run --rm annabell test
```

If you write `.save` or `.logfile` outputs into a bind mount owned by a host user whose UID/GID differs from `1000`, pass `--user "$(id -u):$(id -g)"` to `docker run`.

### Development container (`dev` target)

Build the `dev` target (includes `g++`, GNU Autotools, `libpcre3-dev`, `libgtest-dev`, `git`, `gdb`, and pre-built sources in `/src`):

```bash
docker build --target dev -t annabell:dev .
```

- Run standalone out of the box:

```bash
docker run --rm -it annabell:dev
```

- Mount your local repository for iterative edits and rebuilds:

```bash
docker run --rm -it -v "$PWD:/src" annabell:dev
```

### Using Docker Compose

- Run the `annabell` service interactively (mounts `$PWD` to `/work` by default; override via `ANNABELL_WORKDIR`):

```bash
docker compose run --rm annabell
ANNABELL_WORKDIR=/path/to/data docker compose run --rm annabell
```

- Run the built-in unit tests via Compose:

```bash
docker compose run --rm annabell test
```

- Start the `dev` service (mounts `$PWD` to `/src`):

```bash
docker compose run --rm dev
```

