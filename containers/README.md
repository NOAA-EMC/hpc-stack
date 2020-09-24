# Docker containers
-------------------

This `README.md` describes how to build a hierarchy of Docker containers for use in various applications ranging from NCEPLibs, UFS, GSI, JEDI, and beyond.

There are 3 levels of containers that are made available.  At the very bottom a `BaseContainer` is created that contains only the basic Linux tools such as compilers (`GCC` or `Intel`), MPI implementations (`OpenMPI`, `MPICH` or `Intel MPI`), GNU utils such as `curl`, `wget`, as well as `git`, `cmake`, `vim`, `python`, etc.  [Dockerfile.ubuntu.base](./Dockerfile.ubuntu.base) contains an example of the contents of a `BaseContainer`.

The next level in the hierarchy of containers is an `HPCContainer`.  A `HPCContainer` is built on top of a `BaseContainer` where we build the [hpc-stack](https://github.com/noaa-emc/hpc-stack).  The `hpc-stack` contains all the third-party libraries required for running the applications such as UFS, GSI, JEDI etc.  [Dockerfile.hpc.ubuntu.base](./Dockerfile.hpc.ubuntu.base) contains an example of the contents of a `HPCContainer`.

The top-level in the hierarchy of containers is the `AppContainer`.  An `AppContainer` is built on the `HPCContainer` and typically will contain the application specific tools, codes and static fixed files.  For example, a `UFSContainer` will provide the fix files and static data to compile, build and execute a UFS application.

## How to build Docker containers:
To build these containers, follow the documentation from [Docker](https://docker.com).  Simple examples to create and use the containers are given below as a cheat-sheet.

To build a `Ubuntu` `BaseContainer` called `ncep_base` using this [Dockerfile.ubuntu.base](./Dockerfile.ubuntu.base):

```
$> docker build -t ncep_base:ubuntu -f Dockerfile.ubuntu.base .
$> docker images
REPOSITORY   TAG      IMAGE ID       CREATED       SIZE
ncep_base    ubuntu   c5925a4ef101   6 hours ago   596MB
```

Once the `Ubuntu` `BaseContainer` named `ncep_base` is built, one can build a `HPCContainer` called `hpc_base` using `ncep_base` and this [Dockerfile.hpc.ubuntu.base](./Dockerfile.hpc.ubuntu.base):

```
$> docker build -t hpc_base:ubuntu -f Dockerfile.hpc.base .
$> docker images
REPOSITORY   TAG      IMAGE ID       CREATED       SIZE
hpc_base     ubuntu   4c9391132310   5 hours ago   4.69GB
ncep_base    ubuntu   c5925a4ef101   6 hours ago   596MB
```

## How to start/stop a Docker container:
To start a docker container image e.g. `hpc_base` and `ssh` into it:

```
$> docker run -it <dockerImageName>
```

NOTE: Once you log out or exit out of the container, your local work will be lost.  To save work on the local disk see Docker documentation.
