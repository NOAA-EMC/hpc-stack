#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="ips/18.0.1.163"
export HPC_MPI="impi/18.0.1"
export HPC_PYTHON="python/3.6.3"

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

# WCOSS Dell specific
# LMod has disabled "default"
# https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html
export LMOD_EXTENDED_DEFAULT="yes"

# Load these basic modules
module purge
module load cmake/3.16.2
module use -a /usrx/local/dev/modulefiles
module load git/2.14.3
