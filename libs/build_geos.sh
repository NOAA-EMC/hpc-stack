#!/bin/bash
#
# GEOS - https://trac.osgeo.org/geos/
# GEOS (Geometry Engine - Open Source) is a C++ port of the JTS Topology Suite (JTS). It aims to contain the complete functionality of JTS in C++.

set -eux

name="geos"
version=${1:-${STACK_geos_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load cmake
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
  prefix=${GEOS_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export CFLAGS="${STACK_CFLAGS:-} ${STACK_hdf5_CFLAGS:-} -fPIC -w"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_hdf5_CXXFLAGS:-} -fPIC -w"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://download.osgeo.org/geos/$software.tar.bz2"

[[ -d $software ]] || ( $WGET $URL; tar -xf $software.tar.bz2 )
[[ ${DOWNLOAD_ONLY:-} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ -d build ]] && rm -rf build

cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=$prefix
cd build
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
