FROM ubuntu:14.04

#
# PREREQUISITES
#

# - miscellaneous
RUN apt-get update -y
RUN apt-get install -y curl git build-essential libboost-all-dev qemu qemu-utils libyaml-cpp-dev libssl-dev \
    unzip p11-kit maven autoconf git zip libxml2-utils xsltproc libwxbase3.0-dev libncurses5-dev libglu1-mesa-dev \
    freeglut3-dev mesa-common-dev wx3.0-headers libnuma-dev libibverbs-dev libtool flex bison cmake zlib1g-dev \
    libopenmpi-dev openmpi-bin qt4-dev-tools libqt4-dev libqt4-opengl-dev freeglut3-dev libqtwebkit-dev gnuplot \
    libreadline-dev libncurses-dev libxt-dev libscotch-dev libcgal-dev software-properties-common ed
# - GO
RUN curl https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz | tar xz -C /usr/local && \
    mv /usr/local/go /usr/local/go1.7 && \
    ln -s /usr/local/go1.7 /usr/local/go
ENV GOPATH=/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$GOBIN:/usr/local/go/bin:$PATH
# - oracle JDK
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update -y && \
    apt-get install -y oracle-java8-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#
# PREPARE ENVIRONMENT
#

# - prepare directories
RUN mkdir /git-repos /result
# - clone and build OSv
WORKDIR /git-repos
RUN git clone https://github.com/cloudius-systems/osv.git
WORKDIR /git-repos/osv
RUN git submodule update --init --recursive
RUN make -j6
# - clone mike-apps
WORKDIR /git-repos/osv
RUN git clone https://github.com/mikelangelo-project/mike-apps.git
# - clone and build Capstan
RUN go get github.com/mikelangelo-project/capstan && \
    go install github.com/mikelangelo-project/capstan

#
# PRECOMPILE
#

RUN make -C modules/libtools -j 6
RUN make -C modules/httpserver -j 6
RUN make -C mike-apps/OpenFOAM -j 6

#
# TEMPORARY (refactor me)
#

RUN apt-get update -y
RUN apt-get install -y realpath

#
# OBTAIN RECIPES AND RUN
#

COPY docker_files /
WORKDIR /git-repos/osv
CMD python /capstan-packages.py; echo "\n--- Script exited, container will now sleep ---\n"; sleep infinity

#
# NOTES
#
# Build this container with (add --no-cache flag to rebuild also OSv):
# docker build -t mikelangelo/capstan-packages .
#
# Run this container with:
# docker run -it --volume="$PWD/result:/result" mikelangelo/capstan-packages
#
