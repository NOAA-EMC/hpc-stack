#!/bin/bash

set -eux

name="libtiff"
version=${1:-${STACK_libtiff_version}}

[[ ${STACK_libtiff_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module try-load cmake
    module load zlib
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
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
    prefix=${LIBTIFF_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CFLAGS="${STACK_CFLAGS:-} ${STACK_libtiff_CFLAGS:-} -fPIC"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://gitlab.com/${name}/${name}.git"
[[ -d $software ]] || ( git clone $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

sourceDir=$PWD
cd build
cmake $sourceDir \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DZLIB_ROOT=${ZLIB_ROOT} 
#
make -j${NTHREADS:-4}
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
