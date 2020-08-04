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
