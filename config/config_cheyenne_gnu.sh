#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/9.1.0"
export HPC_MPI="mpt/2.22"

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

# Load these basic modules for Cheyenne
module load cmake/3.16.4
