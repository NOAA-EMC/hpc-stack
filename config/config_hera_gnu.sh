#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/9.2.0"
export HPC_MPI="mpich/3.3.2"
export HPC_PYTHON="miniconda3/3.7.3"

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

# Load these basic modules for Hera
module purge
module load cmake/3.16.1

# To find miniconda3/3.7.3
module use /scratch1/NCEPDEV/nems/emc.nemspara/soft/modulefiles

