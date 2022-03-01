#!/bin/bash

# PROJ - https://proj.org/
# PROJ is a generic coordinate transformation software that transforms geospatial coordinates from one coordinate reference system (CRS) to another.

set -eux

name="proj"
version=${1:-${STACK_proj_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load cmake
  module load sqlite
  module try-load libtiff
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
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
  prefix=${PROJ_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export CFLAGS="${STACK_CFLAGS:-} ${STACK_hdf5_CFLAGS:-} -fPIC -w"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_hdf5_CXXFLAGS:-} -fPIC -w"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://download.osgeo.org/proj/$software.tar.gz"

[[ -d $software ]] || ( $WGET $URL; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ -d build ]] && rm -rf build

CMAKE_OPTS=${STACK_proj_cmake_opts:-""}

[[ $MAKE_CHECK =~ [yYtT] ]] || CMAKE_OPTS+=" -DBUILD_TESTING=OFF"

if [[ -n ${LIBTIFF_ROOT-} ]] ; then
  CMAKE_OPTS+=" -DTIFF_INCLUDE_DIR=${LIBTIFF_ROOT}/include "
  [[ -f ${LIBTIFF_ROOT}/lib64/libtiff.so ]] && CMAKE_OPTS+=" -DTIFF_LIBRARY=${LIBTIFF_ROOT}/lib64/libtiff.so " || CMAKE_OPTS+=" -DTIFF_LIBRARY=${LIBTIFF_ROOT}/lib/libtiff.so "
fi

if [[ -n ${SQLITE_ROOT-} ]] ; then
  CMAKE_OPTS+=" -DSQLITE3_INCLUDE_DIR=${SQLITE_ROOT}/include "
  CMAKE_OPTS+=" -DSQLITE3_LIBRARY=${SQLITE_ROOT}/lib/libsqlite3.so "
fi

LIB_DIR=${SQLITE_ROOT:-} cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=$prefix $CMAKE_OPTS
cd build
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
