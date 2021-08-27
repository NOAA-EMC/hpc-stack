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

module purge
module load envvar/1.0
module load PrgEnv-intel/8.1.0
module load intel/19.1.3.304
module load craype/2.7.8
module load cray-mpich/8.1.7
module load cmake/3.18.4
module load git/2.29.0

export SERIAL_CC=cc
export SERIAL_FC=ftn
export SERIAL_CXX=CC

export MPI_CC=$SERIAL_CC
export MPI_FC=$SERIAL_FC
export MPI_CXX=$SERIAL_CXX

module load hdf5/1.10.6
export HDF5_ROOT=$HDF5_DIR
module load netcdf/4.7.4
export NETCDF_ROOT=$NETCDF_DIR
module load jasper/2.0.25
module load libjpeg/9c
module load libpng/1.6.37
