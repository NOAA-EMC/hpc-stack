#!/bin/bash

set -ex

name="png"
version=${1:-${STACK_png_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module load zlib/${STACK_zlib_version}
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${PNG_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CFLAGS="-fPIC"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
gitURL="https://github.com/glennrp/libpng"
[[ -d $software ]] || ( git clone -b "v$version" $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
sourceDir=$PWD
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake $sourceDir \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DZLIB_ROOT=${ZLIB_ROOT}

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
