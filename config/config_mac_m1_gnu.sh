#!/bin/bash

# Use Lmod for modules definition
source /opt/homebrew/opt/lmod/init/profile

# Compiler/MPI combination
export HPC_COMPILER="gnu/11.2.0"
export HPC_MPI="openmpi/4.1.2"
export HPC_PYTHON="python/3.8.9"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv --no-check-certificate "

#
# gfortran-10 needs the following
export STACK_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"

export CC=/opt/homebrew/bin/gcc
export FC=/opt/homebrew/bin/gfortran
export CXX=/opt/homebrew/bin/g++

export SERIAL_CC=/opt/homebrew/bin/gcc
export SERIAL_FC=/opt/homebrew/bin/gfortran
export SERIAL_CXX=/opt/homebrew/bin/g++

