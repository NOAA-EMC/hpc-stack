#!/bin/bash

# Compiler/MPI combination
#export HPC_COMPILER="intel/2019.5"
#export HPC_MPI="impi/2019.6"
#export HPC_COMPILER="intel/2018.4"
#export HPC_MPI="impi/2018.4"
export HPC_COMPILER="intel/2020"
export HPC_MPI="impi/2020"
#export HPC_COMPILER="gcc/8.3.0"
#export HPC_MPI="openmpi/4.0.2"
export HPC_PYTHON="python/3.7.5"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"

# Load these basic modules for Orion
module purge
module load cmake
module load git
