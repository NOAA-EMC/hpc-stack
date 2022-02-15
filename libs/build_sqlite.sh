#!/bin/bash

# SQLite - https://www.sqlite.org/
# SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine.

set -eux

name="sqlite"
version=${1:-${STACK_sqlite_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

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
  prefix=${SQLITE_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC

export CFLAGS="${STACK_CFLAGS:-} ${STACK_hdf5_CFLAGS:-} -fPIC -w"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software="sqlite-autoconf-${version:0:1}${version:2:2}0${version:5:1}00"
URL="https://www.sqlite.org/2020/$software.tar.gz"
[[ -d $software ]] || ( $WGET $URL; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

./configure --prefix=$prefix
make V=$MAKE_VERBOSE -j${NTHREADS:-4}
$SUDO make V=$MAKE_VERBOSE -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
