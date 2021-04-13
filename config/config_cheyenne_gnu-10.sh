#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/10.1.0"
export HPC_MPI="mpt/2.22"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=Y
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"

module purge
module unuse /glade/u/apps/ch/modulefiles/default/compilers
module use   /glade/p/ral/jntp/GMTB/tools/compiler_mpi_modules/compilers
export MODULEPATH_ROOT=/glade/p/ral/jntp/GMTB/tools/compiler_mpi_modules

module load gnu/10.1.0
module load mpt/2.22
module load ncarcompilers/0.5.0
module load ncarenv/1.3

# Load these basic modules for Cheyenne
module load cmake/3.18.2

# gfortran-10 compatibility flags for incompatible software
export STACK_esmf_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz"
