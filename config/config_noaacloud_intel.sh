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
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=Y
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv --no-check-certificate"

module purge
module load intel/2021.3.0
module load impi/2021.3.0
module load intelpython/2021.3.0
module load cmake/3.20.1

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"

export SERIAL_CC=icc
export SERIAL_FC=ifort
export SERIAL_CXX=icpc

