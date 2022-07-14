#!/bin/bash
# Create a conda environment with additional packages for ufs-srweather-app

if  $MODULES; then
    module load hpc-$HPC_COMPILER
    module load miniconda3/${STACK_miniconda3_version:-}
    module list
fi

name="srwconda"
echo "STACK_miniconda3_version = ${STACK_miniconda3_version:-}"
[[ -n "${CONDA_ENVS_PATH:-}" ]] && echo "CONDA_ENVS_PATH = ${CONDA_ENVS_PATH}"
[[ -n "${CONDA_PKGS_DIR:-}" ]] && echo "CONDA_PKGS_DIR = ${CONDA_PKGS_DIR}"

version=${2:-${STACK_srwconda_version:-}}
pyvenv=${3:-${STACK_srwconda_pyvenv:-}}
[[ -n $pyvenv ]] &&  echo "STACK_srwconda_pyvenv = ${STACK_srwconda_pyvenv:-}"

host=$(uname -s)

if [[ "$host" == "Darwin" ]]; then
  os="MacOSX"
elif [[ "$host" == "Linux" ]]; then
  os="Linux"
else
  echo "Unsupported host $host for srwconda; ABORT!"
  exit 1
fi

set +x

# Check for a conda environment file
if [ -n "$pyvenv" ]; then
  rqmts="$pyvenv.yml" && rqmts_file=${HPC_STACK_ROOT}/pyvenv/$rqmts
  if [ -f "$rqmts_file" ]; then
# Remove the old conda environment if it exists
    if [ -d "$CONDA_ENVS_PATH/$pyvenv" ]; then
      echo " conda env remove -n $pyvenv  "
      conda env remove -n $pyvenv 
    fi
# Create the conda environment
#    echo "executing ... conda env -n $pyvenv create --file $rqmts_file"
#    conda env create -n $pyvenv --file $rqmts_file
    echo "executing ... conda env create --file $rqmts_file"
    conda env create --file $rqmts_file
  else
    echo "Unable to find environment file for $pyvenv environment: $rqmts "
    echo "Search path: $rqmts_file "
    echo "ABORT!"
    exit 1
  fi
fi

software=$name-$version

# Environment created, add it to the contents
echo $name $version  >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
