#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gcc/10.2.0"
export HPC_MPI="openmpi/4.0.4"
export HPC_PYTHON="python/3.9.2"

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
module load gcc/10.2.0
module load openmpi/4.0.4
module load cmake/3.22.1
module load python/3.9.2
module load git/2.28.0
module load cdo/1.9.10
module load geos/3.8.1
module load sqlite/3.32.3
module load proj/7.1.0

# gfortran-10 needs the following
export STACK_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"
#
export CC=gcc
export FC=gfortran
export CXX=g++
#

