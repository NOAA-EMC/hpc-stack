#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/18.0.4"
export HPC_MPI="impi/18.0.4"
export HPC_PYTHON="miniconda/3.8-s4"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"
export VENVTYPE="condaenv"

# Load these basic modules for S4
module purge
module load license_intel/S4
module load git/2.30.0
