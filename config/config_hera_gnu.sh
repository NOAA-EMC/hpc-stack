#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/9.2.0"
export HPC_MPI="openmpi/3.1.4"
export HPC_PYTHON="miniconda3/4.6.14"

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
module load gnu/9.2.0
module load cmake/3.20.1
module load openmpi/3.1.4

# gfortran-10 compatibility flags for incompatible software
#export STACK_esmf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
#export STACK_pnetcdf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
#export STACK_madis_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"
#export STACK_fms_FFLAGS="-march=core-avx2 -fallow-argument-mismatch"

export CC=gcc
export CXX=g++
export FC=gfortran

# Miniconda3 URL on Hera
export STACK_miniconda3_URL="https://repo.anaconda.com"
# Madis, wgrib2, boost - tar files from github
export STACK_git_url="https://github.com/natalie-perlin/HPC-stack-NOAA-blocked-downloads/blob/main/"

export SERIAL_CC=gcc
export SERIAL_CXX=g++
export SERIAL_FC=gfortran

export MPI_CC=mpicc 
export MPI_CXX=mpicxx
export MPI_FC=mpifort

