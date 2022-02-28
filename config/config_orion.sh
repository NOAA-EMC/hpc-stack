#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/2018.4"
export HPC_MPI="impi/2018.4"
export HPC_PYTHON="miniconda3/4.6.14"

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
export WGET="wget -nv --no-check-certificate"
export VENVTYPE="condaenv"

# Load these basic modules for Orion
module purge
module load cmake
module load git

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"
