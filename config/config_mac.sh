#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="clang/12.0.5"
export HPC_MPI="mpich/3.3.2"
export HPC_PYTHON="python/3.9.4"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=6
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"

# gfortran-10 needs the following
#export STACK_mpi_FFLAGS="-fallow-argument-mismatch"
#export STACK_esmf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
