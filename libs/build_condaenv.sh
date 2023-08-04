#!/bin/bash

set -eux

name=$1

var="STACK_${name}_version"
set +u
stack_version=${!var}
set -u
version=${2:-$stack_version}

var="STACK_${name}_requirements"
set +u
stack_rqmts=${!var}
set -u
rqmts=${stack_rqmts:-"$name.yml"}

# Check for conda environment file
rqmts_file=${HPC_STACK_ROOT}/pyvenv/$rqmts
[[ ! -f $rqmts_file ]] && ( echo "Unable to find environment file: $rqmts \nABORT!"; exit 1 )

python=$(echo $HPC_PYTHON | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_PYTHON
  module list
  set -x
  prefix="${PREFIX:-"/opt/modules"}/$python/$name/$version"
  if [[ -d $prefix ]]; then
            if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
  fi
else
  nameUpper=$(echo $name | tr [a-z] [A-Z])
  eval prefix="\${${nameUpper}_ROOT:-'/usr/local'}"
  export CONDA_ROOT=$prefix
  export CONDARC=$CONDA_ROOT/.condarc
  export CONDA_ENVS_PATH=$CONDA_ROOT/envs
  export CONDA_PKGS_DIRS=$CONDA_ROOT/pkgs
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Disable error trapping of unbound variables
# Conda is full of them, and we cannot debug conda
set +u

# Activate conda's base environment to get a few details such as python_version
set +x
echo "executing ... conda activate base"
conda activate base
set -x

# Determine python version; 3.x
python_version=$(python3 -c 'import sys;print(sys.version_info[0],".",sys.version_info[1],sep="")')

# Support python version >= 3.6
min_python_version=3.6
if (( $(echo "$min_python_version >= $python_version" | bc -l) )); then
  echo "Must have python version ($python_version) >= ${min_python_version}. ABORT!"
  exit 1
fi

# Deactivate base environment before building new conda environment
set +x
echo "executing ... conda deactivate"
conda deactivate

# Create the conda environment
echo "executing ... conda env create --file $rqmts_file"
conda env create --file $rqmts_file

# Activate conda environment and get list
echo "executing ... conda activate $name"
conda activate $name
echo "executing ... conda env list"
conda env list
set -x

# Enable error trapping again
set -u

# generate modulefile from template
$MODULES && update_modules python $name $version $python_version
echo $name $version $rqmts_file >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
