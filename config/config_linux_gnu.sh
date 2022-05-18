#!/bin/bash
# Initialize Lmod (customize path, uncomment)
#export BASH_ENV=$HOME/apps/lmod/lmod/init/profile        
#source $BASH_ENV

# Compiler/MPI combination
export HPC_COMPILER="gnu/10.3.0"
export HPC_MPI="mpich/3.3.2"
export HPC_PYTHON="python/3.8.10"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
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
