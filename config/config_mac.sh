#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="clang/11.0.3"
export HPC_MPI="mpich/3.3.1"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"

export SERIAL_FC=gfortran-9
