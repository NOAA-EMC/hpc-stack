#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/9.2.0"
export HPC_MPI="openmpi/3.1.5"

# native-module: load a pre-existing module
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or homebrew.
#             This is a common option for, e.g., gcc/g++/gfortran
# from-source: This is to build from source
export COMPILER_BUILD="from-source"
export MPI_BUILD="from-source"

# Build options
export PREFIX=$HOME/opt
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"
