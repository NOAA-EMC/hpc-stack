#!/bin/bash

# BASH_ENV loads Cray modules each time a new script starts
# Disable that so LMOD isn't overwritten
unset BASH_ENV

# Startup LMOD
source /apps/prod/lmodules/startLmod

# Compiler/MPI combination
#export HPC_COMPILER="cray-intel/19.1.1.217"  # See IMPORTANT NOTE below
export HPC_COMPILER="intel/19.1.1.217"
export HPC_MPI="cray-mpich/8.0.15"

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
# On WCOSS2 the Intel compiler module is "intel/19.1.1.217"
# However, on the Cray, the wrappers are cc, ftn, and CC
# The Intel modules have icc, ifort and icpc for CC, FC and CXX respectively
# By specifying "cray-intel", we load the "hpc-cray-intel" module which
# loads the Intel module (as it should), and
# define cc, FC and CC for CC, FC and CXX respectively.
# cray-intel does not imply the native module in this case

#module purge
module load cmake/3.16.5
module load git/2.27.0
module load cpe-intel

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

# LMod is coming to WCOSS2
# LMod has disabled "default" and requires exact module match.
# https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html
#module load lmod/8.3
#export LMOD_EXACT_MATCH="no"
#export LMOD_EXTENDED_DEFAULT="yes"
