#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/2021.3.0"
export HPC_MPI="impi/2021.3.0"
export HPC_PYTHON="miniconda3/4.12.0"

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
export VENVTYPE="condaenv"

# Load these basic modules for NOAA Cloud
module purge
module load cmake/3.20.1
module load intel/2021.3.0
module load impi/2021.3.0
module use /contrib/EPIC/miniconda3/modulefiles
module load miniconda3/4.12.0

export SERIAL_CC=icc
export SERIAL_CXX=icpc
export SERIAL_FC=ifort
