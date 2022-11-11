#!/bin/bash

set -eux

name="libpng"
version=${1:-${STACK_libpng_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

[[ ${STACK_libpng_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
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
    prefix=${LIBPNG_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CFLAGS="${STACK_CFLAGS:-} ${STACK_libpng_CFLAGS:-} -fPIC"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://github.com/glennrp/libpng"
[[ -d $software ]] || ( git clone -b "v$version" $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
sourceDir=$PWD
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ $enable_shared =~ [yYtT] ]] && shared_flags="" || shared_flags="-DPNG_SHARED=OFF"

cmake $sourceDir \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DZLIB_ROOT=${ZLIB_ROOT} \
  $shared_flags

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make test
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
