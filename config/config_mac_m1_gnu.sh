#!/bin/bash

# Use Lmod for modules definition
source /opt/homebrew/opt/lmod/init/profile

module list
echo "PATH = $PATH"

# Compiler/MPI combination
export HPC_COMPILER="gnu/11.2.0_3"
export HPC_MPI="mpich/3.3.2"
export HPC_PYTHON="python/3.10.2"

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
export STACK_esmf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_madis_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_mapl_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
#
# User specific aliases and functions
export PATH=/opt/homebrew/bin/:$PATH
export LIBDIRS=/opt/homebrew/lib
#
export CC=/opt/homebrew/bin/gcc
export FC=/opt/homebrew/bin/gfortran
export CXX=/opt/homebrew/bin/g++
#
export SERIAL_CC=/opt/homebrew/bin/gcc
export SERIAL_FC=/opt/homebrew/bin/gfortran
export SERIAL_CXX=/opt/homebrew/bin/g++

