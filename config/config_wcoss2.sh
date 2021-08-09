#!/bin/bash

# BASH_ENV loads Cray modules each time a new script starts
# Disable that so LMOD isn't overwritten
unset BASH_ENV

# Compiler/MPI combination
#export HPC_COMPILER="cray-intel/19.1.3.304"  # See IMPORTANT NOTE below
export HPC_COMPILER="intel/19.1.3.304"
export HPC_MPI="cray-mpich/8.1.7"
export HPC_PYTHON="python/3.8.6"

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
export WGET="wget -nv"

# WCOSS2 specific
# NOTE:
# On WCOSS2 the Intel compiler module is "intel/19.1.3.304"
# However, on the Cray, the wrappers are cc, ftn, and CC
# The Intel modules have icc, ifort and icpc for CC, FC and CXX respectively
# By specifying "cray-intel", we load the "hpc-cray-intel" module which
# loads the Intel module (as it should), and
# define cc, FC and CC for CC, FC and CXX respectively.
# cray-intel does not imply the native module in this case

module load PrgEnv-intel/8.1.0
module load cmake/3.20.2
module load git/2.29.0
module load intel/19.1.3.304
module load craype/2.7.8

export SERIAL_CC=cc
export SERIAL_FC=ftn
export SERIAL_CXX=CC

export MPI_CC=$SERIAL_CC
export MPI_FC=$SERIAL_FC
export MPI_CXX=$SERIAL_CXX

# Define the ESMF_COMM variable for WCOSS2
# This is necessary to be done here rather than
# stack_noaa.yaml, to keep one YAML file for NOAA.
export STACK_esmf_comm="mpich3"
export STACK_esmf_os="Linux"
#FMS to build with AVX:
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"
