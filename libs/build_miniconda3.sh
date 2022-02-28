#!/bin/bash

# Download and install Miniconda3
# https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html

set -eux

name="miniconda3"
version=${2:-${STACK_miniconda3_version:-"latest"}}
pyversion=${3:-${STACK_miniconda3_pyversion:-}}

if $MODULES; then
  prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
  if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
          $SUDO mkdir $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
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
pkg_version=$version
[[ -n ${pyversion:-} ]] && pkg_version=${pyversion}_$version
installer="Miniconda3-${pkg_version}-${os}-x86_64.sh"

URL_ROOT=${STACK_miniconda3_URL:-"https://repo.anaconda.com"}
URL="$URL_ROOT/miniconda"

[[ -f $installer ]] || $WGET $URL/$installer
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

$SUDO bash $installer -b -p $prefix -s

# This is a multiuser installation of Miniconda
#https://docs.conda.io/projects/conda/en/latest/user-guide/configuration/admin-multi-user-install.html
export CONDA_ROOT=$prefix
export CONDARC=$CONDA_ROOT/.condarc
export CONDA_ENVS_PATH=$CONDA_ROOT/envs
export CONDA_PKGS_DIR=$CONDA_ROOT/pkgs

set +x
echo "sourcing conda.sh"
PS1=
source $prefix/etc/profile.d/conda.sh
#echo "setting conda default threads to 4"
#conda config --system --set default_threads 4
echo "disabling conda auto updates"
conda config --system --set auto_update_conda False
echo "install $version of conda"
conda install -yq conda=$version
set -x

# generate modulefile from template
$MODULES && update_modules core $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
