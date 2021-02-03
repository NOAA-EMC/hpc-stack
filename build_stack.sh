#!/bin/bash
# The purpose of this script is to build the software stack using
# the compiler/MPI combination
#
# sample usage:
# build_stack.sh -p "prefix" -c "config.sh" -y "stack.yaml" -m
# build_stack.sh -h

set -eu

# root directory for the repository
export HPC_STACK_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ==============================================================================

usage() {
  set +x
  echo
  echo "Usage: $0 -p <prefix> | -c <config> | -y <yaml> -m -h"
  echo
  echo "  -p  installation prefix <prefix>    DEFAULT: $HOME/opt"
  echo "  -c  use configuration file <config> DEFAULT: config/config_custom.sh"
  echo "  -y  use yaml file <yaml>            DEFAULT: config/stack_custom.yaml"
  echo "  -m  use modules                     DEFAULT: NO"
  echo "  -h  display this message and quit"
  echo
  exit 1
}

# ==============================================================================

[[ $# -eq 0 ]] && usage

# Defaults:
export PREFIX="$HOME/opt"
config="${HPC_STACK_ROOT}/config/config_custom.sh"
yaml="${HPC_STACK_ROOT}/config/stack_custom.yaml"
export MODULES=false

while getopts ":p:c:y:mh" opt; do
  case $opt in
    p)
      export PREFIX=$OPTARG
      ;;
    c)
      config=$OPTARG
      ;;
    y)
      yaml=$OPTARG
      ;;
    m)
      export MODULES=true
      ;;
    h|\?|:)
      usage
      ;;
  esac
done

# ==============================================================================

# Source helper functions
source "${HPC_STACK_ROOT}/stack_helpers.sh"

#===============================================================================

# Source the config file
if [[ -e $config ]]; then
  source $config
else
  echo "ERROR: CONFIG FILE $config DOES NOT EXIST, ABORT!"
  exit 1
fi

# Source the yaml to determine software and version
if [[ -e $yaml ]]; then
  eval $(parse_yaml $yaml "STACK_")
else
  echo "ERROR: YAML FILE $yaml DOES NOT EXIST, ABORT!"
  exit 1
fi

# ==============================================================================

compilerName=$(echo $HPC_COMPILER | cut -d/ -f1)
compilerVersion=$(echo $HPC_COMPILER | cut -d/ -f2)

mpiName=$(echo $HPC_MPI | cut -d/ -f1)
mpiVersion=$(echo $HPC_MPI | cut -d/ -f2)

echo "Compiler: $compilerName/$compilerVersion"
echo "MPI: $mpiName/$mpiVersion"

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || export SUDO=""

# ==============================================================================

# create build directory if needed
pkgdir=${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $pkgdir

# This is for the log files
logdir=$HPC_STACK_ROOT/${LOGDIR:-"log"}
mkdir -p $logdir

# ==============================================================================

# start with a clean slate
if $MODULES; then
  source $MODULESHOME/init/bash
  module use $PREFIX/modulefiles/stack
  module load hpc
else
  no_modules
  set_no_modules_path
  set_pkg_root
fi

# ==============================================================================
#----------------------
# Compiler and MPI
build_lib gnu
$MODULES || { [[ ${STACK_gnu_build:-} =~ [yYtT] ]] && export PATH="$PREFIX/bin:$PATH"; }
build_lib mpi
$MODULES || { [[ ${STACK_mpi_build:-} =~ [yYtT] ]] && export PATH="$PREFIX/bin:$PATH"; }

# ==============================================================================
#----------------------
# MPI-independent
# - should add a check at some point to see if they are already there.
# this can be done in each script individually
# it might warrant a --force flag to force rebuild when desired
build_lib cmake
build_lib udunits
build_lib jpeg
build_lib zlib
build_lib png
build_lib szip
build_lib jasper
build_lib gsl

#----------------------
# MPI-dependent
# These must be rebuilt for each MPI implementation
build_lib hdf5
build_lib pnetcdf
build_lib netcdf
build_lib nccmp
build_lib nco
build_lib cdo
build_lib pio

# UFS 3rd party dependencies

build_lib esmf
build_lib fms

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
build_nceplib g2c
build_nceplib g2tmpl
build_nceplib crtm
build_nceplib nceppost
build_nceplib upp
build_nceplib wrf_io
build_nceplib bufr
build_nceplib wgrib2
build_nceplib prod_util
build_nceplib grib_util

# JEDI 3rd party dependencies

build_lib boost
build_lib eigen
build_lib gsl_lite
build_lib gptl
build_lib fftw
build_lib tau2
build_lib cgal
build_lib json
build_lib json_schema_validator

# JCSDA JEDI dependencies

build_lib ecbuild
build_lib eckit
build_lib fckit
build_lib atlas

# ==============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && \
    ( $SUDO rm -rf $pkgdir; $SUDO rm -rf $logdir )

# ==============================================================================
echo "build_stack.sh: SUCCESS!"
