#!/bin/bash

set -eux

name="pybind11"
version=${1:-${STACK_pybind11_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module try-load cmake
    module list
    set -x

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
    prefix=${PYBIND11_ROOT:-"/usr/local"}
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://github.com/pybind/pybind11"
[[ -d $software ]] || ( git clone -b "v$version" $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$prefix \
      -DPYBIND11_TEST=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=1 ..
VERBOSE=$MAKE_VERBOSE $SUDO make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules core $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
