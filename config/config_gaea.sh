#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/18.0.6.288"
export HPC_MPI="cray-mpich/7.7.11"
export HPC_PYTHON="cray-python/3.7.3.2"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=Y
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"

# Load these basic modules for Gaea
module load git/2.26.0
module load cmake/3.20.1
module switch intel/18.0.6.288

export SERIAL_CC=cc
export SERIAL_CXX=CC
export SERIAL_FC=ftn

export MPI_CC=cc
export MPI_CXX=CC
export MPI_FC=ftn

# Load lmod environment
source /lustre/f2/pdata/esrl/gsd/contrib/lua-5.1.4.9/init/init_lmod.sh
