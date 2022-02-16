#!/bin/bash

set -eux

name="gnu"
version=${1:-${STACK_gnu_version}}

software="gcc-$version"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

URL="https://mirrors.tripadvisor.com/gnu/gcc/$software/$software.tar.gz"
[[ -d $software ]] || ( $WGET $URL; tar -xf $software.tar.gz; rm -f $software.tar.gz )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
contrib/download_prerequisites
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

if $MODULES; then
  prefix="${PREFIX:-"/opt/modules"}/$name/$version"
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
  prefix=${GNU_ROOT:-"/usr/local"}
fi

[[ -d build ]] && rm -rf build
mkdir -p build && cd build

extra_conf="--disable-multilib"

../configure -v \
             --prefix=$prefix \
             --enable-checking=release \
             --enable-languages=c,c++,fortran $extra_conf

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
$SUDO make install-strip

# generate modulefile from template
$MODULES && update_modules core $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
