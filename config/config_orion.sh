#!/bin/bash

# Load these basic modules for Orion
module load cmake
module load git

# Compiler/MPI combination
export HPC_COMPILER="intel/2019.5"
export HPC_MPI="impi/2019.6"

# Build options
export PREFIX=/apps/contrib/NCEP/sandbox/rmahajan/trial
export HPC_OPT=${PREFIX}
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=Y
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"

export    STACK_BUILD_CMAKE=N
export  STACK_BUILD_UDUNITS=N
export     STACK_BUILD_JPEG=N
export      STACK_BUILD_PNG=N
export   STACK_BUILD_JASPER=N
export     STACK_BUILD_SZIP=N
export     STACK_BUILD_ZLIB=N
export     STACK_BUILD_HDF5=N
export  STACK_BUILD_PNETCDF=N
export   STACK_BUILD_NETCDF=N
export    STACK_BUILD_NCCMP=N
export      STACK_BUILD_NCO=N
export      STACK_BUILD_PIO=N
export     STACK_BUILD_GPTL=N
export   STACK_BUILD_TKDIFF=N
export     STACK_BUILD_ESMF=Y
export     STACK_BUILD_TAU2=N
