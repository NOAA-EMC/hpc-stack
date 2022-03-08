#!/bin/bash

set -eux

name="gftl-shared"
repo="Goddard-Fortran-Ecosystem"
version=${2:-${STACK_gftl_shared_version:-"main"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
id=${version//\//-}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load cmake
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$id"
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
  prefix=${GFTL_SHARED_ROOT:-"/usr/local"}
fi

software=$name-$id
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://github.com/$repo/$name.git"
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $id
echo $name $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
