


# 1. Specify the base image
FROM ubuntu:latest

LABEL authors="chris"

ENTRYPOINT ["top", "-b"]

# 2. Set environment variables (optional)
ENV MY_APP_VERSION=1.0

# 3. Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-get update -y \
	apt install -y libgtest-dev cmake g++ libpcre3-dev \
	cd /usr/src/gtest \
	cmake CmakeLists.txt \
	make

    && rm -rf /var/lib/apt/lists/*

# 4. Copy the zipped source code from the current directory into the container at /app
COPY annabell.tar.xz /app

# 5. Set the working directory
WORKDIR /app

#Copy, unzip Annabell, and change directory
RUN echo "Setting up Annabell..." \
cd /app \
tar -xvzf /tmp/annabell.tar.xz \
cd annabell \
./configure \
make \
sudo make install \
annabell



# 6. Compile the code
# Replace './configure && make && make install' with your actual build commands
# For example, if it's a C++ project using CMake:
# RUN mkdir build && cd build && cmake .. && make && make install
# Or for a Python project, you might install requirements:
# RUN pip install -r requirements.txt
RUN echo "Replace this with your actual compilation commands"
# Example for a simple C program named main.c:
# COPY main.c /app/
# RUN gcc -o myapp main.c

# 7. Define the runtime command (optional, if the image is meant to run an application)
# This command will run when a container is started from this image.
# Replace './myapp' with the command to run your compiled application.
# CMD ["./myapp"]
CMD ["echo", "Build complete. Replace with your application's entrypoint."]