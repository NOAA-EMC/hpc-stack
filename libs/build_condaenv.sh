#!/bin/bash

set -eux

name=$1

var="STACK_${name}_version"
set +u
stack_version=${!var}
set -u
version=${2:-$stack_version}

var="STACK_${name}_environment"
set +u
stack_rqmts=${!var}
set -u
rqmts=${stack_rqmts:-"environments.yml"}

python=$(echo $HPC_PYTHON | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_PYTHON
  module list
  set -x
  prefix="${PREFIX:-"/opt/modules"}/$python/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  nameUpper=$(echo $name | tr [a-z] [A-Z])
  eval prefix="\${${nameUpper}_ROOT:-'/usr/local'}"
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Check for conda environment file
rqmts_file=${HPC_STACK_ROOT}/pyvenv/$rqmts
[[ ! -f $rqmts_file ]] && ( echo "Unable to find enviroment file: $rqmts \nABORT!"; exit 1 )

# Determine python version; 3.x
python_version=$(python3 -c 'import sys;print(sys.version_info[0],".",sys.version_info[1],sep="")')

# Support python version >= 3.6
min_python_version=3.6
if (( $(echo "$min_python_version >= $python_version" | bc -l) )); then
  echo "Must have python version ($python_version) >= ${min_python_version}. ABORT!"
  exit 1
fi

# Create the conda environment
conda env create --file $rqmts_file -p $prefix

# generate modulefile from template
$MODULES && update_modules python $name $version $python_version
echo $name $version $rqmts_file >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
