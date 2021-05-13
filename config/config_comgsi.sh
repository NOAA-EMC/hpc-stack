#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/18.0.5"
export HPC_MPI="impi/2018.4.274"
export HPC_PYTHON=${HPC_PYTHON:-"python/3.9.4"}

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=Y
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"
