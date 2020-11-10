# Container Development Instructions

------------------------------------

This `container_development.md` will describe how to setup a docker environment which facilitates transforming docker images into singularity images from the local environent (as opposed to transforming a dockerhub based docker image)

## Install Docker

This guide only describes how to install docker on a Ubuntu-based linux environment which has root level permissions.  For a more complete guide of a docker installation for various platforms see this link [here](https://docs.docker.com/engine/install) and for specific platforms see the following links.

- [Docker Desktop for Mac (macOS)](https://docs.docker.com/docker-for-mac/install/)

- [Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install/)

- [Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

- [CentOS](https://docs.docker.com/engine/install/centos/)

1. Uninstall any existing older versions of docker.

```bash
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

2. Setup the repository. Update the apt package index and install packages to allow apt to use a repository over HTTPS.

```bash
$ sudo apt-get update

$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

3. Add Docker’s official GPG key.

```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

4. Verify that you now have the key with the fingerprint `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`, by searching for the last 8 characters of the fingerprint.

```bash
$ sudo apt-key fingerprint 0EBFCD88

pub   rsa4096 2017-02-22 [SCEA]
     9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

5. Use the following command to set up the stable repository. To add the nightly or test repository, add the word nightly or test (or both) after the word stable in the commands below.

```bash
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

6. Install the docker engine. 
    - Update the apt package index, and install the latest version of Docker Engine and containerd, or go to the next step to install a specific version:

```bash
$ sudo apt-get update

$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

7. Verify that Docker Engine is installed correctly by running the hello-world image.

```bash
$ sudo docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:8c5aeeb6a5f3ba4883347d3747a7249f491766ca1caa47e5da5dfcf6b9b717c0
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

8. Add your user to the `docker` group. If you would like to use Docker as a non-root user, you should now consider adding your user to the “docker” group with something like:

```bash
$ sudo usermod -aG docker your-user
```

> Remember to log out and back in for this to take effect!

## Setup a Local Docker Registry

This is the easiest way to enable the transformation into a singularity image mechanism.  You can read more about creating a private registry [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-18-04). The local docker registry service is described [here](https://docs.docker.com/registry/) and a local registry setup guide can be found [here](https://docs.docker.com/registry/deploying/) if you wish to set it up in more complex ways than just localhost.

This guide will walk you through the quick setup instructions which can also be found [here](https://hub.docker.com/_/registry).

1. Start the local registry at port 5000.

```bash
$ docker run -d -p 5000:5000 --restart always --name registry registry:2
```

2. Now, use it from within Docker (there are 3 basic steps to making a docker image available
for a singularity transformation):

    - create the docker image using the `docker build` command
    - tag that image using the `docker tag` command
    - push that image to your local registry using the `docker push` command. in this example, a pre-built docker image is pulled from dockerhub, so instead of pulling an image, simply build the image you wish to transform locally

```bash
$ docker build -t <docker_image_name>:<version> -f <docker_definition_file>
$ docker tag ubuntu localhost:5000/ubuntu
$ docker push localhost:5000/ubuntu
```

# Install Singularity
Now if you haven't already done so, install singularity.  The singularity binary must be built by `go`, so go must be installed first.

1. Install package dependencies.

```bash
$ export DEBIAN_FRONTEND=noninteractive

# package dependencies
$ apt-get update -y
$ apt-get install -y --no-install-recommends \
      build-essential git openssh-server libncurses-dev libssl-dev libx11-dev \
      less bc file flex bison libexpat1-dev wish curl wget libcurl4-openssl-dev \
      libgtk2.0-common software-properties-common xserver-xorg dirmngr gnupg2 \
      lsb-release apt-utils uuid-dev libgpgme11-dev squashfs-tools
```

2. Install Go

    - The minimum required version is determined by the version of Singularity. See the latest singularity documentation for up-to-date information [here](https://sylabs.io/docs/).

```bash
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
```

3. Build and install Singularity

```bash
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
```

4. Validate the installation by running the following command.

```bash
$ singularity --version

singularity version 3.6.3
```

## Create Singularity Image from Local Docker Image

1. First confirm that the image is available on your private registry.

```bash
$ curl localhost:5000/v2/_catalog

# example output (note, look for the docker images which you have tagged and pushed to the registry)
{"repositories":["intel-oneapi-ufs-s2s-dev","intel-oneapi-ufs-s2s-lite"]}
```

2. Transform the docker image into a singularity image. Note, the `SINGULARITY_NOHTTPS=1` ensures that singularity does not try to grab the tagged image from dockerhub.  You want singularity to grab the image from your locally hosted registry, not a remote registry.

```bash
$ SINGULARITY_NOHTTPS=1 singularity build <desired_image_name>.sif docker://localhost:5000/<docker_image_tag_name>
```
> The singularity image should now be ready for use.
