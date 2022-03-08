#!/bin/bash

set -eux

name="esma_cmake"
repo="GEOS-ESM"
version=${2:-${STACK_esma_cmake_version:-"main"}}
id=${version//\//-}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/core/$name/$id"
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
  prefix=${ESMA_CMAKE_ROOT:-"/usr/local"}
fi

software=$name-$id
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://github.com/$repo/$name.git"
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $prefix && cp -r $software/* $prefix

# generate modulefile from template
$MODULES && update_modules core $name $id
echo $name $id $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
