FROM ubuntu:22.04

# install the packages necessary to compile scuff-em,
# and clean up as much as possible afterwards to keep the image small
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      automake \
      libtool \
      flex \
      bison \
      gfortran \
      libreadline-dev \
      libopenblas-dev \
      liblapack-dev \
      libhdf5-serial-dev \
      ca-certificates \
      git \
      python3-dev \
      python3-numpy \
      swig \
    && rm -rf /var/lib/apt/lists/*

# clone the latest scuff-em version from github, compile and install it
RUN cd /tmp \
    && git clone https://github.com/jfeist/scuff-em.git \
    && cd scuff-em \
    && git checkout 83c5ff252a0a69131505f1e4d1c6ca54114738e7 \
    && ./autogen.sh --with-hdf5-includedir=/usr/include/hdf5/serial --with-hdf5-libdir=/usr/lib/$(uname -m)-linux-gnu/hdf5/serial \
    && make -j 4 install \
    && ldconfig \
    && git clean -fxd

# add a "dispatcher" script that can be called as, e.g.,
# "scuff scatter" (which just calls scuff-scatter), and
# which lists the available programs if called without arguments
ADD scuff /usr/local/bin/
RUN chmod +x /usr/local/bin/scuff

# workdir set to /mnt so that we can mount a host directory to /mnt and run commands there
# e.g., "docker -v ${PWD}:/mnt scuff-em scuff-scatter" is the same as
# running "scuff-scatter" from the local machine in the same directory
WORKDIR /mnt

# automatically run the "scuff" script, which delegates to the available scuff programs
# this allows to just do "docker run jfeist/scuff-em" to run the "scuff" script,
# which will list the available subcommands
# any further arguments to docker run will be passed to the script, such that you can
# run scuff-scatter as "docker run -v ${PWD}:/mnt jfeist/scuff-em scatter --geometry ..."
ENTRYPOINT ["scuff"]
