#!/bin/bash

export HPC_COMPILERS=("intel/2018.4" "intel/2019.5" "intel/2020" "gcc/8.3.0")
export HPC_MPIS=("impi/2018.4" "impi/2019.6" "impi/2020" "openmpi/4.0.2")

# Compiler/MPI combination
export HPC_COMPILER=${HPC_COMPILER:-"intel/2020"}
export HPC_MPI=${HPC_MPI:-"impi/2020"}

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
module load cmake
module load git
