#!/bin/bash
# Initialize bash with Lmod (customize path, modify if needed)
if [[ -d "$LMOD_PKG" ]]; then
  export BASH_ENV=$LMOD_PKG/init/profile        
  source $BASH_ENV
fi
# Compiler/MPI combination
export HPC_COMPILER="gnu/11.2.0"
export HPC_MPI="openmpi/4.1.2"
export HPC_PYTHON="python/dummy"

# Load/unload compiler modules and other system modules as needed
# module load gnu/11.2.0
# ... or set the path for compiler binaries as GNU env. variable:
export GNU="/usr/local/bin/"

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

# gfortran-10 (and higher) compatibility flags for incompatible software
export STACK_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"

export CC=${GNU}gcc
export FC=${GNU}gfortran
export CXX=${GNU}g++

export SERIAL_CC=${GNU}gcc
export SERIAL_FC=${GNU}gfortran
export SERIAL_CXX=${GNU}g++
