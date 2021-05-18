#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/19.1.1"
export HPC_MPI="mpt/2.22"
export HPC_PYTHON="python/dummy"

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

module load intel/19.1.1
module load mpt/2.22
module load ncarcompilers/0.5.0
module load ncarenv/1.3

# Load these basic modules for Cheyenne
module load cmake/3.18.2

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"
