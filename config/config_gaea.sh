#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/18.0.6.288"
export HPC_MPI="cray-mpich/7.7.11"

# Build options
export NCO_V=false
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

# Load these basic modules for gaea
module load git/2.26.0
module load cmake/3.17.0
module switch intel/18.0.6.288

# Set compiler environment variables etc.
export SERIAL_CC=cc
export SERIAL_FC=ftn
export SERIAL_CXX=CC

export MPI_CC=$SERIAL_CC
export MPI_FC=$SERIAL_FC
export MPI_CXX=$SERIAL_CXX

# Load lmod environment
source /lustre/f2/pdata/esrl/gsd/contrib/lua-5.1.4.9/init/init_lmod.sh

