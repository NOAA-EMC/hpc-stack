# Software Stack

This repository provides a unified, shell script based build system for building commonly used software stack.

Building the software stack is a **Three-Step process**, as described in the following sections.

## Step 1: Configure Build

The first step is to choose what components of the stack you wish to build and to specify any other aspects of the build that you would like.  This is normally done by editing the files `config/config_custom.sh` and `config/stack_custom.yaml`.  Here we describe some of the parameter settings available.

**COMPILER** This defines the vendor and version of the compiler you wish to use for this build.  The format is the same as what you would typically use in a module load command:
```
export COMPILER=<name>/<version>
```
For example, `COMPILER=gnu/7.3.0`.

**MPI** is the MPI library you wish to use for this build.  The format is the same as for `COMPILER`, for example: `export MPI=openmpi/3.1.2`.

**PREFIX** is the directory where the software packages will be installed.  Normally this is set to be the same as the `HPC_OPT` environment variable (default value `/opt/modules`), though this is not required.  If `HPC_OPT` and `PREFIX` are both the same, then the software installation trees (the top level of each being is the compiler, e.g. `gnu-7.3.0`) will branch directly off of `$HPC_OPT` while the module files will be located in the `modulefiles subdirectory.

**USE_SUDO** If `PREFIX` is set to a value that requires root permission to write to, such as `/opt/modules`, then this flag should be enabled.

_**NOTE: To enable a boolean flag use a single-digit `Y` or `T`.  To disable, use `N` or `F` (case insensitive)**_

**PKGDIR** is the directory where tarred or zipped software files will be downloaded and compiled.  Unlike `PREFIX`, this is a relative path, based on the root path of the repository.  Individual software packages can be downloaded manually to this directory and untarred, but this is not required.  Most build scripts will look for directory `pkg/pkgName-pkgVersion` e.g. `pkg/hdf5-1_10_3`.

**LOGDIR** is the directory where log files from the build will be written, relative to the root path of the repository.

**OVERWRITE** If set, this flag will cause the build script to remove the current installation, if any exists, and replace it with the new version of each software package in question.  If this is not set, the build will bypass software packages that are already installed.

**NTHREADS** The number of threads to use for parallel builds

**MAKE_CHECK** Run `make check` after build

**MAKE_VERBOSE** Print out extra information to the log files during the build

`config/stack_custom.yaml` defines which software packages to be built along with their version.  Other package specific options can be specified.

The following software can optionally be built with the scripts under `libs`. These packages are built in Step 3 using the `build_stack.sh` script.

* Compilers and MPI libraries
  - GNU/GCC
  - Intel/IPS
  - OpenMPI
  - MPICH
  - `hpc-` Meta-modules for all the above as well as Intel and IMPI

* HPC Stack
  - CMake
  - Udunits
  - PNG
  - JPEG
  - Jasper
  - SZip
  - Zlib
  - HDF5
  - PNetCDF
  - NetCDF
  - ParallelIO
  - ncccmp
  - nco
  - FFTW
  - GPTL
  - Tau2
  - FFTW
  - ESMF

* NCEP Libraries
  - NCEPLIBS-bacio
  - NCEPLIBS-sigio
  - NCEPLIBS-sfcio
  - NCEPLIBS-gfsio
  - NCEPLIBS-w3nco
  - NCEPLIBS-sp
  - NCEPLIBS-ip
  - NCEPLIBS-ip2
  - NCEPLIBS-g2
  - NCEPLIBS-g2tmpl
  - NCEPLIBS-nemsio
  - NCEPLIBS-nemsiogfs
  - NCEPLIBS-w3emc
  - NCEPLIBS-landsfcutil
  - NCEPLIBS-bufr
  - NCEPLIBS-wgrib2
  - EMC_crtm
  - EMC_post

**IMPORTANT: Steps 1, 2, and 3 need to be repeated for each compiler/mpi combination that you wish to install.**  The new packages will be installed alongside any previously-existing packages that may already have been built from other compiler/mpi combinations.

## Step 2: Set Up Compiler, MPI, and Module System

Run from the top directory:
```
./setup_modules.sh [<configuration>]
```
where `<configuration>` points to the configuration script that you wish to use, as described in Step 1.  The name of this file is `config/config_<configuration>`.  For example, to use the `config/config_custom.sh` you would enter this:
```
./setup_modules.sh custom
```
If no arguments are specified, the default is `custom`.  Note that you can skip this step as well for container builds because we currenly include only one compiler/mpi combination in each container.  So, each package is only build once and there is no need for modules.

This script sets up the module directory tree in `$HPC_OPT`.  It also sets up the compiler and mpi modules.  The compiler and mpi modules are handled separately from the rest of the build because, when possible, we wish to exploit site-specific installations that maximize performance.

**For this reason, the compiler and mpi modules are preceded by a `hpc-` label**.  For example, to load the gnu compiler module and the openmpi software library, you would enter this:
```
module load hpc-gnu/7.3.0
module load hpc-openmpi/3.2.1
```
These `hpc-` modules are really meta-modules that will both load the compiler/mpi library and modify the `MODULEPATH` so the user has access to the software packages that will be built in Step 4.  On HPC systems, these meta-modules will load the native modules provided by the system administrators.  For example, `module load hpc-openmpi/3.2.1` will first load the native `openmpi/3.2.1` module and then modify the `MODULEPATH` accordingly to allow users to access the custom libraries built by this repository.

So, in short, you should never load the compiler or MPI modules directly.  Instead, you should always load the `hpc-` meta-modules as demonstrated above - they will provide everything you need to load and then use these software libraries.

## Step 3: Build Software Stack

Now all that remains is to build the stack:
```
./build_stack.sh [<configuration>]
```
Here `<configuration>` is the same as in Step 2, namely a reference to the corresponding configuration file in the `config` directory.  As in Step 2, if this argument is omitted, the default is to use `config/config_custom.sh`.

# Adding a New library/package

If you want to add a new library to the stack you need to follow these steps:
1. write a new build script in libs, using exising scripts as a template
2. define a new section in the `yaml` file for that library/package in config directory
3. Add a call to the new build script in `build\_stack.sh`
4. Create a new module template at the appropriate place in the modulefiles directory, using exising files as a template

# Configuring for a new HPC

If you want to port this to a new HPC, you need to follow these steps:
1. Write a new config file in `config`, using existing configs as a template. Also create a new yaml file, using existing yaml files as a template.
2. Add/remove basic modules for that HPC
3. Choose the appropriate Compiler/MPI combination.
4. If a template modulefile does not exist for that Compiler/MPI combinattion, create module templates at the appropriate place in the modulefiles directory, using existing files as a template.

# Using the HPC-stack
To use the HPC-stack, you need to activate the stack.  This is done by loading the `hpc` module  under `$HPC_OPT/modulefiles/stack` as follows:
```
module use $HPC_OPT/modulefiles/stack
module load hpc
```
This will put the `hpc-compiler` module in your `MODULEPATH`, which can be loaded as:
```
module load hpc-compiler
```
