#!/bin/bash

# Use Lmod for modules definition
LMOD=$(brew --prefix lmod)
source $LMOD/init/profile

# Compiler/MPI combination
export HPC_COMPILER="gnu/12.3.0"
export HPC_MPI="openmpi/4.1.5"
export HPC_PYTHON="python/3.11.6"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv "

#
# gfortran-10 needs the following
export STACK_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz -march=native "
export STACK_CFLAGS="-march=native"
export STACK_CXXFLAGS="-march=native"
export STACK_mpi_FFLAGS="-fopenmp"
export STACK_mpi_CFLAGS="-fopenmp"
export STACK_mpi_CXXFLAGS="-fopenmp"

BREW=$(brew --prefix)

export CC=$BREW/bin/gcc
export FC=$BREW/bin/gfortran
export CXX=$BREW/bin/g++

export SERIAL_CC=$BREW/bin/gcc
export SERIAL_FC=$BREW/bin/gfortran
export SERIAL_CXX=$BREW/bin/g++

