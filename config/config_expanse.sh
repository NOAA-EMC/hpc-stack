#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/19.1.1.217"
export HPC_MPI="intel-mpi/2019.8.254"
export HPC_PYTHON="python/3.8.5"


# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"
export VENVTYPE="condaenv"

# Load these basic modules for Expanse
module purge
module load slurm/expanse/20.02.3
module load cpu/0.15.4
module load cmake/3.18.2 

BSD_ROOT="/cm/shared/apps/spack/cpu/opt/spack/linux-centos8-zen/gcc-8.3.1/libbsd-0.10.0-adrl7mon2vjnjxfi462y23wau36kayw3"
EXPANSE_ROOT="/cm/shared/apps/spack/cpu/opt/spack/linux-centos8-zen/gcc-8.3.1/expat-2.2.9-kmhtadv3hnspa5iaijtrnhl65radrebv"
export STACK_udunits_LDFLAGS="-L${EXPANSE_ROOT}/lib -L${BSD_ROOT}/lib"
export STACK_udunits_CFLAGS="-I${EXPANSE_ROOT}/include"

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"

