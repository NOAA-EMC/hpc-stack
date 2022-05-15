#!/bin/bash

# Initialize Lmod and environmental variables
export MODULESHOME=/lustre/f2/pdata/esrl/gsd/contrib/lua-5.1.4.9/lmod/lmod
source $MODULESHOME/init/bash
export PATH=$MODULESHOME/../../bin:$MODULESHOME/init/ksh_funcs:$PATH
#
# Compiler/MPI combination
export HPC_COMPILER="gcc/10.3.0"
export HPC_MPI="openmpi/4.1.2"
export HPC_PYTHON="python/3.6.12"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=Y
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv --no-check-certificate"

# Load these basic modules for Gaea
module load gcc/10.3.0
module load git/2.31.1
module load cmake/3.20.1

# ESMF env. variable
export STACK_esmf_os="Linux"
# gfortran-10 compatibility flags for incompatible software
export STACK_esmf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_pnetcdf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_madis_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2 -fallow-argument-mismatch"

export CC=gcc
export CXX=g++
export FC=gfortran

