#!/bin/bash

set -eux

name="yafyaml"
repo=${1:-${STACK_yafyaml_repo:-"Goddard-Fortran-Ecosystem"}}
version=${2:-${STACK_yafyaml_version:-"main"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
id=${version//\//-}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load cmake
  module load gftl-shared
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$repo-$id"
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

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $repo-$id
echo $name $repo-$id $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
