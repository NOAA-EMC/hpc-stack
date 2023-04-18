#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/2021.3.0"
export HPC_MPI="cray-mpich/7.7.11"
export HPC_PYTHON="miniconda3/4.12.0"

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
export WGET="wget -nv"

# Load lmod environment
source /lustre/f2/dev/role.epic/contrib/Lmod_init.sh
#
module load cmake/3.20.1
module load intel/2021.3.0
module load cray-mpich/7.7.11
module use /lustre/f2/dev/role.epic/contrib/modulefiles
module load miniconda3/4.12.0
module load git/2.31.1
module load git-lfs

export SERIAL_CC=icc
export SERIAL_CXX=icpc
export SERIAL_FC=ifort

export MPI_CC=cc
export MPI_CXX=CC
export MPI_FC=ftn

