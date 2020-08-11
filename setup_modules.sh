#!/bin/bash

# The purpose of this script is to define the compiler and MPI library to be
# used and to set up and deploy the associated modules.  This needs to be each
# time a different compiler/MPI build is initiated.
#
# Arguments:
# compiler name/version and MPI Library/version: these are the names of the
# modules that this script is responsible for creating and that build_stack.sh
# will use to build the software stack.
#
# sample usage
# setup_modules.sh "custom"
#

set -e

# currently supported configuration options
supported_options=("custom")

# root directory for the repository
HPC_BUILDSCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export HPC_STACK_ROOT=$HPC_BUILDSCRIPTS_DIR

#===============================================================================
# First source the config file

if [[ $# -ne 1 ]]; then
  source ${HPC_BUILDSCRIPTS_DIR}/config/config_custom.sh
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

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

#===============================================================================
# Deploy directory structure for modulefiles

$SUDO mkdir -p $HPC_OPT/modulefiles/core
$SUDO mkdir -p $HPC_OPT/modulefiles/compiler/$compilerName/$compilerVersion
$SUDO mkdir -p $HPC_OPT/modulefiles/mpi/$compilerName/$compilerVersion/$mpiName/$mpiVersion

$SUDO mkdir -p $HPC_OPT/modulefiles/core/hpc-$compilerName
$SUDO cp $HPC_STACK_ROOT/modulefiles/core/hpc-$compilerName/hpc-$compilerName.lua \
         $HPC_OPT/modulefiles/core/hpc-$compilerName/$compilerVersion.lua

$SUDO mkdir -p $HPC_OPT/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName
$SUDO cp $HPC_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/hpc-$mpiName/hpc-$mpiName.lua \
         $HPC_OPT/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName/$mpiVersion.lua

#===============================================================================

# Deploy directory for stack modulefile
$SUDO mkdir -p $HPC_OPT/modulefiles/stack/hpc
$SUDO cp $HPC_STACK_ROOT/modulefiles/stack/hpc/hpc.lua \
         $HPC_OPT/modulefiles/stack/hpc/1.0.0.lua

# Replace #HPC_OPT# from template with $HPC_OPT,
# sed does not like delimiter (/) to be a part of replacement string, do magic!
cd $HPC_OPT/modulefiles/stack/hpc
repl=$(echo ${HPC_OPT} | sed -e "s#/#\\\/#g")
$SUDO sed -i -e "s/#HPC_OPT#/${repl}/g" $HPC_OPT/modulefiles/stack/hpc/1.0.0.lua

#===============================================================================

echo "setup_modules.sh $1: success!"
echo "To proceed run: build_stack.sh $1"

exit 0
