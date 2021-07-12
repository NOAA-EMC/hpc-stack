#!/bin/bash

# Download and install Miniconda3
# https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html

set -eux

name="miniconda3"
version=${2:-${STACK_miniconda3_version:-"latest"}}

if $MODULES; then
  prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${MINICONDA3_ROOT:-"/usr/local"}
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

host=$(uname -s)

if [[ "$host" == "Darwin" ]]; then
  os="MacOSX"
elif [[ "$host" == "Linux" ]]; then
  os="Linux"
else
  echo "Unsupported host $host for Miniconda3; ABORT!"
  exit 1
fi

software=$name-$version
installer="Miniconda3-${version}-${os}-x86_64.sh"
URL="https://repo.anaconda.com/miniconda/$installer"

[[ -d $software ]] || ( mkdir -p $software; $WGET $URL -O $software/$installer )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

$SUDO bash $software/$installer -b -p $prefix

# generate modulefile from template
$MODULES && update_modules core $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
