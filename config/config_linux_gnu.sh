#!/bin/bash
# Initialize Lmod (customize path, modify if needed)
export BASH_ENV=$LMOD_PKG/init/profile        
source $BASH_ENV

# Compiler/MPI combination
export HPC_COMPILER="gnu/11.2.0"
export HPC_MPI="openmpi/4.1.2"
export HPC_PYTHON="python/dummy"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=Y
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv --no-check-certificate"

# gfortran-10 compatibility flags for incompatible software
export STACK_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"

export CC=gcc
export FC=gfortran
export CXX=g++

export SERIAL_CC=gcc
export SERIAL_FC=gfortran
export SERIAL_CXX=g++
