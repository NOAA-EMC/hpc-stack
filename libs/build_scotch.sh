#!/bin/bash

set -eux

name="scotch"
version=${1:-${STACK_scotch_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')
id=$(echo $version | sed 's/v//')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module load cmake
  module load netcdf
  module load gnu
  module list
  set -x
  
  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$id"
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
  prefix=${SCOTCH_ROOT:-"/usr/local"}
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://gitlab.inria.fr/scotch/scotch/-/archive/$version/scotch-$version.tar.gz"
[[ -f $software.tar.gz ]] || ( $WGET $URL )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

[[ -f $software.tar.gz ]] && tar -xvf $software.tar.gz || ( echo "$software tarfile does not exist, ABORT!"; exit 1 )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

# Compile & Install Scotch/PTscotch
cmake VERBOSE=1 -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_C_COMPILER=icc -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release ..

make VERBOSE=1
make install
make scotch
make ptscotch

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $id
echo $name $id $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
