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
# setup_modules.sh -p "prefix" -c "config.sh"
# setup_modules.sh -h
#

set -eu

# root directory for the repository
HPC_STACK_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

HPC_STACK_VERSION="$(head -n 1 ${HPC_STACK_ROOT}/VERSION)"

#===============================================================================

usage() {
  set +x
  echo
  echo "Usage: $0 -p <prefix> | -c <config> | -h"
  echo
  echo "  -p  installation prefix <prefix>    DEFAULT: $HOME/opt"
  echo "  -c  use configuration file <config> DEFAULT: config/config_custom.sh"
  echo "  -h  display this message and quit"
  echo
  exit 1
}

#===============================================================================

[[ $# -eq 0 ]] && usage

# Defaults:
PREFIX="$HOME/opt"
config="${HPC_STACK_ROOT}/config/config_custom.sh"

while getopts ":p:c:h" opt; do
  case $opt in
    p)
      PREFIX=$OPTARG
      ;;
    c)
      config=$OPTARG
      ;;
    h|\?|:)
      usage
      ;;
  esac
done

#===============================================================================

# Source the config file
if [[ -e $config ]]; then
  source $config
else
  echo "ERROR: CONFIG FILE $config DOES NOT EXIST, ABORT!"
  exit 1
fi

#===============================================================================

compilerName=$(echo $HPC_COMPILER | cut -d/ -f1)
compilerVersion=$(echo $HPC_COMPILER | cut -d/ -f2)

mpiName=$(echo $HPC_MPI | cut -d/ -f1)
mpiVersion=$(echo $HPC_MPI | cut -d/ -f2)

echo "Compiler: $compilerName/$compilerVersion"
echo "MPI: $mpiName/$mpiVersion"

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && SUDO="sudo" || SUDO=""

#===============================================================================
# Deploy directory structure for modulefiles

$SUDO mkdir -p $PREFIX/modulefiles/core
$SUDO mkdir -p $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion
$SUDO mkdir -p $PREFIX/modulefiles/mpi/$compilerName/$compilerVersion/$mpiName/$mpiVersion

$SUDO mkdir -p $PREFIX/modulefiles/core/hpc-$compilerName
$SUDO mkdir -p $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName

$SUDO mkdir -p $PREFIX/modulefiles/stack/hpc

#===============================================================================
# Are the hpc-$compilerName.lua, hpc-$mpiName.lua or hpc/stack.lua modulefiles present at $PREFIX?
# If yes, query the user to ask to over-write
if [[ -f $PREFIX/modulefiles/core/hpc-$compilerName/$compilerVersion.lua ]]; then
  echo "WARNING: $PREFIX/modulefiles/core/hpc-$compilerName/$compilerVersion.lua exists!"
  echo "Do you wish to over-write? [yes|YES|no|NO]: (DEFAULT: NO)  "
  read response
else
  response="YES"
fi
[[ $response =~ [yYtT] ]] && overwriteCompilerModulefile=YES
unset response

if [[ -f $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName/$mpiVersion.lua ]]; then
  echo "WARNING: $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName/$mpiVersion.lua exists!"
  echo "Do you wish to over-write? [yes|YES|no|NO]: (DEFAULT: NO)  "
  read response
else
  response="YES"
fi
[[ $response =~ [yYtT] ]] && overwriteMPIModulefile=YES
unset response

if [[ -f $PREFIX/modulefiles/stack/hpc/$HPC_STACK_VERSION.lua ]]; then
  echo "WARNING: $PREFIX/modulefiles/stack/hpc/$HPC_STACK_VERSION.lua exists!"
  echo "Do you wish to over-write? [yes|YES|no|NO]: (DEFAULT: NO)  "
  read response
else
  response="YES"
fi
[[ $response =~ [yYtT] ]] && overwriteStackModulefile=YES
unset response

#===============================================================================
# Query the user if using native compiler and MPI, if overwriting (or writing for first time)
if [[ ${overwriteCompilerModulefile:-} =~ [yYtT] ]]; then
  $SUDO cp $HPC_STACK_ROOT/modulefiles/core/hpc-$compilerName/hpc-$compilerName.lua \
           $PREFIX/modulefiles/core/hpc-$compilerName/$compilerVersion.lua
  echo "Are you using native compiler $compilerName [yes|YES|no|NO]: (DEFAULT: NO)  "
  read response
  if [[ $response =~ [yYtT] ]]; then
    echo -e "==========================\n USING NATIVE COMPILER"
    cd $PREFIX/modulefiles/core/hpc-$compilerName
    $SUDO sed -i -e '/load(compiler)/d' $compilerVersion.lua
    $SUDO sed -i -e '/prereq(compiler)/d' $compilerVersion.lua
    [[ -f $compilerVersion.lua-e ]] && $SUDO rm -f "$compilerVersion.lua-e" # Stupid macOS does not understand -i, and creates a backup with -e (-e is the next sed option)
    echo
  fi
  unset response
fi

if [[ ${overwriteMPIModulefile:-} =~ [yYtT] ]]; then
  $SUDO cp $HPC_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/hpc-$mpiName/hpc-$mpiName.lua \
           $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName/$mpiVersion.lua
  echo "Are you using native MPI $mpiName [yes|YES|no|NO]: (DEFAULT: NO)  "
  read response
  if [[ $response =~ [yYtT] ]]; then
    echo -e "===========================\n USING NATIVE MPI"
    cd $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName
    $SUDO sed -i -e '/load(mpi)/d' $mpiVersion.lua
    $SUDO sed -i -e '/prereq(mpi)/d' $mpiVersion.lua
    [[ -f $mpiVersion.lua-e ]] && $SUDO rm -f "$mpiVersion.lua-e"
    echo
  fi
  unset response
fi

if [[ ${overwriteStackModulefile:-} =~ [yYtT] ]]; then
  $SUDO cp $HPC_STACK_ROOT/modulefiles/stack/hpc/hpc.lua \
           $PREFIX/modulefiles/stack/hpc/$HPC_STACK_VERSION.lua
  # Replace #PREFIX# from template with $PREFIX,
  # sed does not like delimiter (/) to be a part of replacement string, do magic!
  cd $PREFIX/modulefiles/stack/hpc
  repl=$(echo ${PREFIX} | sed -e "s#/#\\\/#g")
  $SUDO sed -i -e "s/#HPC_OPT#/${repl}/g" $PREFIX/modulefiles/stack/hpc/$HPC_STACK_VERSION.lua
  [[ -f $HPC_STACK_VERSION.lua-e ]] && $SUDO rm -f "$HPC_STACK_VERSION.lua-e"
fi

#===============================================================================

echo "setup_modules.sh: SUCCESS!"
echo "To proceed run: build_stack.sh -p $PREFIX -c $config -y <stack.yaml>"

exit 0
