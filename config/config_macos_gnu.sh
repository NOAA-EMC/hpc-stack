#!/bin/bash

# Use Lmod for modules definition
source $LMOD_PKG/init/profile

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

[[ -f "/opt/homebrew/bin/gcc" ]] && export GNU=/opt/homebrew/bin
[[ -f "/usr/local/bin/gcc" ]] && export GNU=/usr/local/bin
export CC=$GNU/gcc
export FC=$GNU/gfortran
export CXX=$GNU/g++

export SERIAL_CC=$CC 
export SERIAL_FC=$FC 
export SERIAL_CXX=$CXX

