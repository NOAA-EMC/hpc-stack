#!/bin/bash

set -eux

name="jpeg"
version=${1:-${STACK_jpeg_version}}

[[ ${STACK_jpeg_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${JPEG_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CFLAGS="${STACK_CFLAGS:-} ${STACK_jpeg_CFLAGS:-} -fPIC"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
gitURL="https://github.com/LuaDist/libjpeg"
[[ -d $software ]] || ( git clone $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
sourceDir=$PWD
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ $enable_shared =~ [yYtT] ]] && shared_flags="" || shared_flags="-DBUILD_STATIC=ON"
[[ $MAKE_CHECK =~ [yYtT] ]] && check_flags="-DBUILD_TESTS=ON"

cmake $sourceDir \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DBUILD_EXECUTABLES=ON \
  -DCMAKE_BUILD_TYPE=RELEASE ${shared_flags:-} ${check_flags:-}

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make test

$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
