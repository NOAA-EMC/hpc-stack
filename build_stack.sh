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

# ==============================================================================
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
source "${HPC_BUILDSCRIPTS_DIR}/stack_helpers.sh"

# this is needed to set environment variables if modules are not used
$MODULES || no_modules $1

# Parse config/stack_$1.yaml to determine software and version
eval $(parse_yaml config/stack_$1.yaml "STACK_")

# create build directory if needed
pkgdir=${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $pkgdir

# This is for the log files
logdir=$HPC_STACK_ROOT/$LOGDIR
mkdir -p $logdir

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

# ==============================================================================

# start with a clean slate
if $MODULES; then
  module use $HPC_OPT/modulefiles/stack
  module load hpc
fi

# ==============================================================================
#----------------------
# Compiler and MPI
build_lib gnu
build_lib mpi

# ==============================================================================
#----------------------
# MPI-independent
# - should add a check at some point to see if they are already there.
# this can be done in each script individually
# it might warrant a --force flag to force rebuild when desired
#build_lib cmake
#build_lib udunits
#build_lib jpeg
#build_lib zlib
#build_lib png
#build_lib szip
#build_lib jasper
#
##----------------------
## MPI-dependent
## These must be rebuilt for each MPI implementation
#build_lib hdf5
#build_lib pnetcdf
#build_lib netcdf
#build_lib nccmp
#build_lib nco

#build_lib pio
build_lib esmf

build_lib gptl
build_lib fftw
build_lib tau2

# NCEPlibs
build_nceplib bacio
build_nceplib sigio
build_nceplib sfcio
build_nceplib gfsio
build_nceplib w3nco
build_nceplib sp
build_nceplib ip
build_nceplib ip2
build_nceplib landsfcutil
build_nceplib nemsio
build_nceplib nemsiogfs
build_nceplib w3emc
build_nceplib g2
build_nceplib g2tmpl
build_nceplib crtm
build_nceplib nceppost
build_nceplib wrf_io
build_nceplib bufr
build_nceplib wgrib2

# ==============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && \
    ( $SUDO rm -rf $pkgdir; $SUDO rm -rf $logdir )

# ==============================================================================
echo "build_stack.sh $1: success!"
