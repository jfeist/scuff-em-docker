FROM ubuntu:latest

# install the packages necessary to compile scuff-em,
# and clean up as much as possible afterwards to keep the image small
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
      git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

# clone the latest scuff-em version from github, compile and install it, and then
# delete the build directory (again to keep the image small)
RUN cd /tmp && \
    git clone https://github.com/HomerReid/scuff-em.git && \
    cd scuff-em && \
    ./autogen.sh && \
    make -j 4 install && \
    ldconfig && \
    cd .. && \
    rm -r scuff-em

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
