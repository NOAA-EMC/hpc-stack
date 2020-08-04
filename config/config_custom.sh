#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/9.2.0"
export HPC_MPI="openmpi/4.0.1"

# This tells hpc-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or homebrew.
#             This is a common option for, e.g., gcc/g++/gfortran
# from-source: This is to build from source
export COMPILER_BUILD="native-pkg"
export MPI_BUILD="from-source"

# Build options
export PREFIX=/opt/modules
export USE_SUDO=Y
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"
