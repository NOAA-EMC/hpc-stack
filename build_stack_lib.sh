#!/bin/bash
# The purpose of this script is to build a single library in the
# software stack using the compiler/MPI combination
#
# sample usage:
# build_stack_lib.sh -p "prefix" -c "config.sh" -y "stack.yaml" -m -l "library_name"
# build_stack_lib.sh -h

set -eu

# root directory for the repository
export HPC_STACK_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# ==============================================================================

usage() {
  set +x
  echo
  echo "Usage: $0 -l <library> | -p <prefix> | -c <config> | -y <yaml> -m -h"
  echo
  echo "  -l  library to install <library>    DEFAULT: NONE, REQUIRED"
  echo "  -p  installation prefix <prefix>    DEFAULT: $HOME/opt"
  echo "  -c  use configuration file <config> DEFAULT: config/config_custom.sh"
  echo "  -y  use yaml file <yaml>            DEFAULT: config/stack_custom.yaml"
  echo "  -m  use modules                     DEFAULT: NO"
  echo "  -h  display this message and quit"
  echo
  exit 1
}

# ==============================================================================
# Defaults:
unset LIBRARY
export PREFIX="$HOME/opt"
config="${HPC_STACK_ROOT}/config/config_custom.sh"
yaml="${HPC_STACK_ROOT}/config/stack_custom.yaml"
export MODULES=false

while getopts ":l:p:c:y:mh" opt; do
  case $opt in
    l)
      LIBRARY=$OPTARG
      ;;
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

# Make sure required arguments are provided
shift "$(( OPTIND - 1 ))"
set +u
if [ -z "$LIBRARY" ]; then
  echo 'Missing -l <library' >&2
  usage
fi
set -u

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
# Echo compiler, mpi and build information
compilermpi_info
echo "build: $LIBRARY | version: ${STACK_\${LIBRARY}_version}"
# ==============================================================================
# Build desired library
build_lib $LIBRARY

# ==============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && \
    ( $SUDO rm -rf $pkgdir; $SUDO rm -rf $logdir )

# ==============================================================================
echo "build_stack_lib.sh: SUCCESS!"
