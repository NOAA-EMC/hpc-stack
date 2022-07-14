#!/bin/bash
# Initialize Lmod (customize path, uncomment)
#export BASH_ENV=$HOME/apps/lmod/lmod/init/profile        
#source $BASH_ENV
# Load the module with GNU/GCC compilers, or initialize GNU variable 
# as path for compiler binaries
# GNU="/usr/local/bin"
export GNU=${GNU:-}

# Compiler/MPI combination
export HPC_COMPILER="gnu/10.3.0"
export HPC_MPI="openmpi/4.1.2"
export HPC_PYTHON="python/3.8.9"

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
export VENVTYPE="condaenv"

# gfortran-10 compatibility flags for incompatible software
export STACK_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"

export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"

export CC=$GNU/gcc
export FC=$GNU/gfortran
export CXX=$GNU/g++

export SERIAL_CC=$GNU/gcc
export SERIAL_FC=$GNU/gfortran
export SERIAL_CXX=$GNU/g++
