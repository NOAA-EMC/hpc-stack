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
rqmts=${stack_rqmts:-"$name.txt"}

# Check for requirements file
rqmts_file=${HPC_STACK_ROOT}/pyvenv/$rqmts
[[ ! -f $rqmts_file ]] && ( echo "Unable to find requirements file: $rqmts \nABORT!"; exit 1 )

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
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=${name}-${version}
mkdir -p $software

# Determine python version; 3.x
python_version=$(python3 -c 'import sys;print(sys.version_info[0],".",sys.version_info[1],sep="")')

# Support python version >= 3.6
min_python_version=3.6
if (( $(echo "$min_python_version >= $python_version" | bc -l) )); then
  echo "Must have python version ($python_version) >= ${min_python_version}. ABORT!"
  exit 1
fi

# Download the requirements of the virtual environment
if [[ ${DOWNLOAD_ONLY} =~ [yYtT] ]]; then
  pip download -r $rqmts_file -d $software
  exit 0
fi

# for python >= v3.9, upgrade dependencies (pip, setuptools) in place with '--upgrade-deps'
upgrade_deps=""
if (( $(echo "$python_version >= 3.9" | bc -l) )); then
  upgrade_deps="--upgrade-deps"
fi

# Create a new virtual env.
python3 -m venv --prompt $name $upgrade_deps $prefix

# Activate newly created virtual env.
set +x
source $prefix/bin/activate
set -x

# Upgrade pip
pip install --upgrade pip

# Install packages from $rqmt_file
[[ -z "$(ls -A $software)" ]] || pip_args="--no-index --find-links $software"
pip install --no-cache-dir -r $rqmts_file ${pip_args:-}

# List installed packages
pip list

# generate modulefile from template
$MODULES && update_modules python $name $version $python_version
echo $name $version $rqmts_file >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
