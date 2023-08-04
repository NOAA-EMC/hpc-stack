#!/bin/bash

# Compiler/MPI combination
export HPC_PYTHON=${HPC_PYTHON:-"python/3.6.8"}
export HPC_COMPILER=${HPC_COMPILER:-"intel/2020.0"}
export HPC_MPI=${HPC_MPI:-"impi/2020u0"}

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv --no-check-certificate "

module purge
export BASH_ENV=$HOME/apps/lmod/lmod/init/bash # Point to the new definition of Lmod

source $BASH_ENV                              # Redefine the module command to point
                                              # to the new Lmod
module use $HOME/modulefiles
module load cmake
module load intel/2020.0
module load impi/2020u0
#

export CC=icc
export FC=ifort
export CXX=icpc

export SERIAL_CC=icc
export SERIAL_FC=ifort
export SERIAL_CXX=icpc

export MPI_CC=mpiicc
export MPI_FC=mpiifort
export MPI_CXX=mpiicpc

#
