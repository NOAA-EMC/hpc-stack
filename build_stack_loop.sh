#!/bin/bash

set -eu

# root directory for the repository
export HPC_STACK_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

prefix="$HOME/opt"

HPC_COMPILERS=("gnu/9.3.0")
HPC_MPIS=("mpich/3.3.2")

for index in ${!HPC_COMPILERS[*]}; do
	export HPC_COMPILER=${HPC_COMPILERS[$index]}
	export HPC_MPI=${HPC_MPIS[$index]}

	setup_modules.sh -p $prefix -c config/config_custom.yaml
	build_stack.sh -p $prefix -c config/config_custom.yaml -y -m

done
