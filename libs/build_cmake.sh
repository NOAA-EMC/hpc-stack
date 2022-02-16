#!/bin/bash

# Building cmake from source is sometimes preferable to package installs
# because it allows you to get the most up-to-date versions and it
# allows you to place it into a module context so you can experiment
# with different versions

set -eux

name="cmake"
version=${1:-${STACK_cmake_version}}

if $MODULES; then
    module load hpc-$HPC_COMPILER
    module list

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
    prefix=${CMAKE_ROOT:-"/usr/local"}
fi

software=$name-$version
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://cmake.org/files/v${version%.*}/$software.tar.gz"
[[ -d $software ]] || ( $WGET $URL; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export FC=$SERIAL_FC

# CMake must be available if boostrap is set to no
if [[ ${STACK_cmake_bootstrap:-} =~ [nNfF] ]]; then
    cmake . -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE:STRING=Release
else
    $SUDO ./bootstrap --prefix=$prefix -- -DCMAKE_BUILD_TYPE:STRING=Release
fi

$SUDO make -j${NTHREADS:-4}
$SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
