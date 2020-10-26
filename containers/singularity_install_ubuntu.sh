#!/bin/bash

# Install Singularity
# execute this as root

set -ex
export DEBIAN_FRONTEND=noninteractive

# package dependencies
apt-get update -y
apt-get install -y --no-install-recommends \
      build-essential git openssh-server libncurses-dev libssl-dev libx11-dev \
      less bc file flex bison libexpat1-dev wish curl wget libcurl4-openssl-dev \
      libgtk2.0-common software-properties-common xserver-xorg dirmngr gnupg2 \
      lsb-release apt-utils uuid-dev libgpgme11-dev squashfs-tools

# install Go
# The minimum required version is determined by the version of Singularity
# See the latest singularity documentation for up-to-date information:
# https://sylabs.io/docs/#singularity
if [ -z "${HOME:-}" ]; then export HOME="$(cd ~ && pwd)"; fi
cd ${HOME}
export VERSION=1.15.2 OS=linux ARCH=amd64
wget -nv --no-check-certificate https://golang.org/dl/go$VERSION.$OS-$ARCH.tar.gz
tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
rm -f go$VERSION.$OS-$ARCH.tar.gz
echo 'export GOPATH=${HOME}/go' >> ${HOME}/.bashrc
echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ${HOME}/.bashrc
export GOPATH=${HOME}/go
export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin

# build and install Singularity
PREFIX=/opt/singularity
mkdir -p ${PREFIX}
cd ${PREFIX}
export VERSION=3.6.3
wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz
tar -xzf singularity-${VERSION}.tar.gz
cd singularity
./mconfig
make -C builddir
make -C builddir install
rm ${PREFIX}/singularity-${VERSION}.tar.gz

DEBIAN_FRONTEND=noninteractive
APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

apt-get update -y && \
apt-get install -y --no-install-recommends -o=Dpkg::Use-Pty=0 \
build-essential \
pkg-config \
cmake \
ca-certificates \
gnupg
