#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/2022.1.2"
export HPC_MPI="impi/2022.1.2"
export HPC_PYTHON="miniconda3/4.12.0"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=Y
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv --no-check-certificate"
export VENVTYPE="condaenv"

# Load these basic modules for Hera
module purge
module load cmake/3.20.1
module load intel/2022.1.2
module load impi/2022.1.2
module load intelpyton3/2022.1.2

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"
 
# Use alternative URL to download tar files
# Miniconda3 URL on Hera
# Miniconda3 URL on Hera
export STACK_miniconda3_URL="https://repo.anaconda.com"
# Madis, wgrib2, boost - tar files from github
export STACK_git_URL="https://github.com/natalie-perlin/HPC-stack-NOAA-blocked-downloads/blob/main"

export CC=icc
export CXX=icpc
export FC=ifort

export SERIAL_CC=icc
export SERIAL_CXX=icpc
export SERIAL_FC=ifort

