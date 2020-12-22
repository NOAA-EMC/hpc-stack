#!/bin/bash

set -eux

# root directory for the repository
export HPC_STACK_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage() {
  set +x
  echo
  echo "Usage: $0 -p <prefix> | -c <config> | -y <yaml> -h"
  echo
  echo "  -p  installation prefix <prefix>    DEFAULT: $HOME/opt"
  echo "  -c  use configuration file <config> DEFAULT: config/config_custom.sh"
  echo "  -y  use yaml file <yaml>            DEFAULT: config/stack_custom.yaml"
  echo "  -h  display this message and quit"
  echo
  exit 1
}


# Defaults:
export PREFIX="$HOME/opt"
config="${HPC_STACK_ROOT}/config/config_custom.sh"
yaml="${HPC_STACK_ROOT}/config/stack_custom.yaml"

while getopts ":p:c:y:h" opt; do
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
    h|\?|:)
      usage
      ;;
  esac
done

# Source the config file
if [[ -e $config ]]; then
    source $config
else
    echo "ERROR: CONFIG FILE $config DOES NOT EXIST, ABORT!"
    exit 1
fi

if [[ -z ${HPC_COMPILERS+x} ]]; then
    echo "HPC_COMPILERS array must be set in config to use loop_stack.sh"
    exit 1
fi

if [[ -z ${HPC_MPIS+x} ]]; then
    echo "HPC_MPIS array must be set in config to use loop_stack.sh"
    exit 1
fi

for index in ${!HPC_COMPILERS[*]}; do
    export HPC_COMPILER=${HPC_COMPILERS[$index]}
    export HPC_MPI=${HPC_MPIS[$index]}
    
    ${HPC_STACK_ROOT}/setup_modules.sh -O -p $PREFIX -c $config
done


for index in ${!HPC_COMPILERS[*]}; do
    export HPC_COMPILER=${HPC_COMPILERS[$index]}
    export HPC_MPI=${HPC_MPIS[$index]}
  
    ${HPC_STACK_ROOT}/build_stack.sh -p $PREFIX -c $config -y $yaml -m
done
