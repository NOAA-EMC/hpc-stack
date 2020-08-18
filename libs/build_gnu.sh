#!/bin/bash

set -eux

name="gnu"
version=${1:-${STACK_gnu_version}}

software="gcc-$version"

[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

prefix="${PREFIX:-"$HOME/opt"}/$name/$version"
[[ -d $prefix ]] && ( echo "$prefix exists, ABORT!"; exit 1 )

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

url="https://mirrors.tripadvisor.com/gnu/gcc/$software/$software.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
contrib/download_prerequisites
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

extra_conf="--disable-multilib"

../configure -v \
             --prefix=$prefix \
             --enable-checking=release \
             --enable-languages=c,c++,fortran $extra_conf

make -j${NTHREADS:-4}
$SUDO make install-strip

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
