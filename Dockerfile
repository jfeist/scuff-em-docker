FROM ubuntu:latest

RUN apt-get -y update && apt-get -y install build-essential automake libtool flex bison \
    gfortran libreadline-dev libopenblas-dev liblapack-dev libhdf5-serial-dev git

RUN cd ${HOME} && git clone https://github.com/HomerReid/scuff-em.git && cd scuff-em && \
    ./autogen.sh && make -j 4 && make install && ldconfig && cd .. && rm -r scuff-em

ADD scuff /usr/local/bin/
RUN chmod +x /usr/local/bin/scuff

# workdir set to /mnt so that we can mount a host directory to /mnt and run commands there
# e.g., "docker -v ${PWD}:/mnt scuff-em scuff-scatter" is the same as
# running "scuff-scatter" from the local machine in the same directory
WORKDIR /mnt

# automatically run the "scuff" script, which delegates to the available scuff programs
ENTRYPOINT ["scuff"]
