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

#===============================================================================
# Deploy directory structure for modulefiles

mkdir -p $PREFIX/modulefiles/core
mkdir -p $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion
mkdir -p $PREFIX/modulefiles/mpi/$compilerName/$compilerVersion/$mpiName/$mpiVersion

mkdir -p $PREFIX/modulefiles/core/hpc-$compilerName
cp $HPC_STACK_ROOT/modulefiles/core/hpc-$compilerName/hpc-$compilerName.lua \
   $PREFIX/modulefiles/core/hpc-$compilerName/$compilerVersion.lua

mkdir -p $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName
cp $HPC_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/hpc-$mpiName/hpc-$mpiName.lua \
   $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName/$mpiVersion.lua

#===============================================================================
# Query the user if using native compiler and MPI
echo "Are you using native compiler $compilerName [yes|YES|no|NO]: (DEFAULT: NO)  "
read responseCompiler
if [[ $responseCompiler =~ [yYtT] ]]; then
  echo -e "==========================\n USING NATIVE COMPILER"
  cd $PREFIX/modulefiles/core/hpc-$compilerName
  sed -i -e '/load(compiler)/d' $compilerVersion.lua
  sed -i -e '/prereq(compiler)/d' $compilerVersion.lua
  [[ -f $compilerVersion.lua-e ]] && rm -f "$compilerVersion.lua-e" # Stupid macOS does not understand -i, and creates a backup with -e (-e is the next sed option)
  echo
fi

echo "Are you using native MPI $mpiName [yes|YES|no|NO]: (DEFAULT: NO)  "
read responseMPI
if [[ $responseMPI =~ [yYtT] ]]; then
  echo -e "===========================\n USING NATIVE MPI"
  cd $PREFIX/modulefiles/compiler/$compilerName/$compilerVersion/hpc-$mpiName
  sed -i -e '/load(mpi)/d' $mpiVersion.lua
  sed -i -e '/prereq(mpi)/d' $mpiVersion.lua
  [[ -f $mpiVersion.lua-e ]] && rm -f "$mpiVersion.lua-e"
  echo
fi

#===============================================================================

# Deploy directory for stack modulefile
mkdir -p $PREFIX/modulefiles/stack/hpc
cp $HPC_STACK_ROOT/modulefiles/stack/hpc/hpc.lua \
   $PREFIX/modulefiles/stack/hpc/$HPC_STACK_VERSION.lua

# Replace #PREFIX# from template with $PREFIX,
# sed does not like delimiter (/) to be a part of replacement string, do magic!
cd $PREFIX/modulefiles/stack/hpc
repl=$(echo ${PREFIX} | sed -e "s#/#\\\/#g")
sed -i -e "s/#HPC_OPT#/${repl}/g" $HPC_STACK_VERSION.lua
[[ -f $HPC_STACK_VERSION.lua-e ]] && rm -f "$HPC_STACK_VERSION.lua-e"

#===============================================================================

echo "setup_modules.sh: SUCCESS!"
echo "To proceed run: build_stack.sh -p $PREFIX -c $config -y <stack.yaml>"

exit 0
