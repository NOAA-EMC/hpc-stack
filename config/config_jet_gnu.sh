#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/9.2.0"
export HPC_MPI="openmpi/3.1.4"
export HPC_PYTHON="python/3.6.8"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv --no-check-certificate"

# Bypass unused variable bug in LMod version on Jet when sourcing the LMod setup
export __lmod_vx=""

# Load these basic modules for Hera
module purge
module load gnu/9.2.0
module load cmake/3.20.1
module load openmpi/3.1.4
# Use alternative URL to download tar files
# Miniconda3 URL 
export STACK_miniconda3_URL="https://repo.anaconda.com"
# Madis, wgrib2, boost - tar files from github
export STACK_git_URL="https://github.com/natalie-perlin/HPC-stack-NOAA-blocked-downloads/blob/main"
# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"
export CC=gcc
export CXX=g++
export FC=gfortran

export SERIAL_CC=gcc
export SERIAL_CXX=g++
export SERIAL_FC=gfortran

export MPI_CC=mpicc
export MPI_CXX=mpicxx
export MPI_FC=mpifort
