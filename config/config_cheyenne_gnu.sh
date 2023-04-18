#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/10.1.0"
export HPC_MPI="mpt/2.25"
export HPC_PYTHON="python/dummy"

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
export WGET="wget -nv"

module purge
module load ncarenv/1.3
module load gnu/10.1.0
module load mpt/2.25
module load cmake/3.22.0
module load sqlite/3.36.0

# gfortran-10 compatibility flags for incompatible software
export STACK_esmf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_pnetcdf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
export STACK_madis_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2 -fallow-argument-mismatch"
# Patch FMS
export STACK_fms_PATCH="cheyenne_gnu_fms_mpp_util_mpi_inc.patch"

