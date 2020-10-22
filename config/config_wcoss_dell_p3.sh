#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="ips/18.0.1.163"
export HPC_MPI="impi/18.0.1"

# Build options
export NCO_V=false
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=Y
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"

if $NCO_V; then
 module load mpi_third/ips/19.0.5/impi/19.0.5/HDF5-parallel/1.10.1
 module load mpi_third/ips/18.0.1/impi/18.0.1/NetCDF-parallel/4.7.4
 module load jasper/1.900.29
# module load libjpeg/
 module load libpng/1.2.59
 module load zlib/1.2.11

 export NetCDF_CONFIG_EXECUTABLE=/usrx/local/dev/packages/ips/18.0.1/impi/18.0.1/netcdf/4.7.4/bin/nc-config
 export NetCDF_PARALLEL=true
 export NetCDF_HAS_PNETCDF=True
 export NetCDF_PARALLEL=True
 export NetCDF_PATH=/usrx/local/dev/packages/ips/18.0.1/impi/18.0.1/netcdf/4.7.4
fi
# WCOSS Dell specific
# LMod has disabled "default" and requires exact module match.
# https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html
export LMOD_EXACT_MATCH="no"
export LMOD_EXTENDED_DEFAULT="yes"

# Load these basic modules
module load cmake/3.16.2
