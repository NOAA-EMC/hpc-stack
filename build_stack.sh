#!/bin/bash
# The purpose of this script is to build the software stack using
# the compiler/MPI combination defined by setup_modules.sh
#
# Arguments:
# configuration: Determines which libraries will be installed.
#     Each supported option will have an associated config_<option>.sh
#     file that will be used to
#
# sample usage:
# build_stack.sh "custom"

set -e

# currently supported configuration options
supported_options=("custom")

# root directory for the repository
HPC_BUILDSCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export HPC_STACK_ROOT=${HPC_BUILDSCRIPTS_DIR}

# ===============================================================================
# First source the config file

if [[ $# -ne 1 ]]; then
    source "${HPC_BUILDSCRIPTS_DIR}/config/config_custom.sh"
else
    config_file="${HPC_BUILDSCRIPTS_DIR}/config/config_$1.sh"
    if [[ -e $config_file ]]; then
      source $config_file
    else
      echo "ERROR: CONFIG FILE $config_file DOES NOT EXIST!"
      echo "Currently supported options: "
      echo ${supported_options[*]}
      exit 1
    fi

fi

HPC_OPT=${HPC_OPT:-$OPT}
if [ -z "$HPC_OPT" ]; then
    echo "Set HPC_OPT to modules directory (suggested: $HOME/opt/modules)"
    exit 1
fi

compilerName=$(echo $HPC_COMPILER | cut -d/ -f1)
compilerVersion=$(echo $HPC_COMPILER | cut -d/ -f2)

mpiName=$(echo $HPC_MPI | cut -d/ -f1)
mpiVersion=$(echo $HPC_MPI | cut -d/ -f2)

echo "Compiler: $compilerName/$compilerVersion"
echo "MPI: $mpiName/$mpiVersion"

# Source helper functions
#source "${HPC_BUILDSCRIPTS_DIR}/libs/update_modules.sh"
source "${HPC_BUILDSCRIPTS_DIR}/stack_helpers.sh"

# this is needed to set environment variables if modules are not used
$MODULES || no_modules $1

# create build directory if needed
pkgdir=${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $pkgdir

# This is for the log files
logdir=$HPC_STACK_ROOT/$LOGDIR
mkdir -p $logdir

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

# ===============================================================================

# start with a clean slate
if $MODULES; then
  module use $HPC_OPT/modulefiles/core
  module load hpc-stack
fi

# ===============================================================================
# Minimal HPC Stack
#----------------------
# MPI-independent
# - should add a check at some point to see if they are already there.
# this can be done in each script individually
# it might warrant a --force flag to force rebuild when desired
build_lib CMAKE cmake 3.17.2
build_lib UDUNITS udunits 2.2.26
build_lib JPEG jpeg 9.1.0
build_lib ZLIB zlib 1.2.11
build_lib PNG png 1.6.35
build_lib SZIP szip 2.1.1
build_lib JASPER jasper 2.0.15
build_lib TKDIFF tkdirr 4.3.5

#----------------------
# These must be rebuilt for each MPI implementation
build_lib HDF5 hdf5 1.10.6
build_lib PNETCDF pnetcdf 1.12.1
build_lib NETCDF netcdf 4.7.3 4.5.2 4.3.0
build_lib NCCMP nccmp 1.8.6.5

# ===============================================================================
# Optional Extensions to the HPC Stack

#----------------------
# These must be rebuilt for each MPI implementation
build_lib GPTL gptl 8.0.2
build_lib NCO nco 4.7.9
build_lib PIO pio 2.5.0
build_lib FFTW fftw 3.3.8
build_lib ESMF esmf 8_0_0
build_lib TAU2 tau2 3.25.1

# ===============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && \
    ( $SUDO rm -rf $pkgdir; $SUDO rm -rf $logdir )

# ===============================================================================
echo "build_stack.sh $1: success!"
