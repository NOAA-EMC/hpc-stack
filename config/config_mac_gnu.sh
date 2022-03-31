#!/bin/bash

# Use Lmod for modules definition
source /usr/local/opt/lmod/init/profile   

module list
echo "PATH = $PATH"

# Compiler/MPI combination
export HPC_COMPILER="gnu/11.2.0_3"
export HPC_MPI="mpich/3.3.2"
export HPC_PYTHON="python/3.9.11"

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
export WGET="wget -nv --no-check-certificate "

#
# gfortran-10 needs the following
export STACK_esmf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_madis_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_mapl_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
#
# User specific aliases and functions
export PATH=/usr/local/bin/:$PATH
export LIBDIRS=/usr/local/lib
#
export CC=/usr/local/bin/gcc
export FC=/usr/local/bin/gfortran
export CXX=/usr/local/bin/g++
#
export SERIAL_CC=/usr/local/bin/gcc
export SERIAL_FC=/usr/local/bin/gfortran
export SERIAL_CXX=/usr/local/bin/g++
