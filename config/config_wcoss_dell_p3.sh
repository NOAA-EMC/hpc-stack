#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="ips/18.0.1.163"
export HPC_MPI="impi/18.0.1"

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

# Load these basic modules for WCOSS Dell
module load cmake/3.16.2
