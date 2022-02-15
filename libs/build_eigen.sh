#!/bin/bash

set -eux

name="eigen"
version=${1:-${STACK_eigen_version}}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load boost-headers
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
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
  prefix=${EIGEN_ROOT:-"/usr/local"}
fi

cd $HPC_STACK_ROOT/${PKGDIR:-"pkg"}

URL="https://gitlab.com/libeigen/eigen.git"

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$prefix
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
