#!/bin/bash

set -ex

name="zstd"
version=${1:-${STACK_zstd_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER)

[[ ${STACK_zstd_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
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
    prefix=${ZSTD_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export FFLAGS="${STACK_FFLAGS:-} ${STACK_zstd_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_zstd_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_zstd_CXXFLAGS:-} -fPIC"
export FCFLAGS="$FFLAGS"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL=https://github.com/facebook/zstd.git
[[ -d $software ]] || ( git clone -b v$version $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software/build/cmake || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ -d build ]] && rm -rf build
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_INSTALL_LIBDIR=lib

make -j${NTHREADS:-4}
[[ "$MAKE_CHECK" = "YES" ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
