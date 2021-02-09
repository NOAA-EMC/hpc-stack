#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER=${HPC_COMPILER:-"intel/oneapi-2021.1.1"}
export HPC_MPI=${HPC_MPI:-"impi/oneapi-2021.1.1"}

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"
