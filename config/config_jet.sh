#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/2022.1.2"
export HPC_MPI="impi/2022.1.2"
export HPC_PYTHON="miniconda3/4.12.0"

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

# Bypass unused variable bug in LMod version on Jet when sourcing the LMod setup
export __lmod_vx=""

module load cmake/3.20.1

module load intel/2022.1.2
module load impi/2022.1.2
module use /mnt/lfs4/HFIP/hfv3gfs/role.epic/miniconda3/modulefiles
module load miniconda3/4.12.0
