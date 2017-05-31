FROM ubuntu:14.04

# Install prerequisites
RUN apt-get update -y
RUN apt-get install -y curl git build-essential libboost-all-dev qemu qemu-utils

# Prepare folders
RUN mkdir git-repos /result

# Clone OSv from GitHub
RUN cd git-repos && \
    git clone https://github.com/cloudius-systems/osv.git

WORKDIR git-repos/osv    
    
RUN git submodule update --init --recursive
RUN make -j3

# Install GO
RUN curl https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz | tar xz -C /usr/local && \
    mv /usr/local/go /usr/local/go1.7 && \
    ln -s /usr/local/go1.7 /usr/local/go
ENV GOPATH=/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$GOBIN:/usr/local/go/bin:$PATH

# Build Capstan from source
RUN go get github.com/mikelangelo-project/capstan && \      
    go install github.com/mikelangelo-project/capstan

# Copy files into container
COPY docker_files /

CMD python /capstan-packages.py; echo "\n--- Script exited, container will now sleep ---\n"; sleep infinity

#
# NOTES
#
# Build this container with (add --no-cache flag to rebuild also OSv):
# docker build -t mikelangelo-project/capstan-packages .
#
# Run this container with:
# docker run -it --volume="$PWD/result:/result" mikelangelo-project/capstan-packages
#
