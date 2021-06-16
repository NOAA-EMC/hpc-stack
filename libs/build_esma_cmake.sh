#!/bin/bash

set -eux

name="esma_cmake"
repo=${1:-${STACK_esma_cmake_repo:-"GEOS-ESM"}}
version=${2:-${STACK_esma_cmake_version:-"main"}}
id=${version//\//-}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/core/$name/$repo-$id"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${CMAKEMODULES_ROOT:-"/usr/local"}
fi

software=$name-$repo-$id
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://github.com/$repo/$name.git"
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git fetch --tags
git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $prefix && cp -r $software/* $prefix

# generate modulefile from template
$MODULES && update_modules core $name $repo-$id
echo $name $repo-$id $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
