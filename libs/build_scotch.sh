#!/bin/bash

set -eux

name="scotch"
version=${1:-${STACK_scotch_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-"v"$version
URL="https://gitlab.inria.fr/scotch/scotch/-/archive/v${version}/scotch-v${version}.tar.gz"
[[ -f $software.tar.gz ]] || ( $WGET $URL )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module load cmake/3.20.1
  module load netcdf/4.9.0
  module load gnu
  module list
  set -x
  
  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
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

tar -xvf $software.tar.gz; cd $software
mkdir build; cd build

#SCOTCH_PREFIX=${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}/$software

#cmake VERBOSE=1 -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_C_COMPILER=icc -DCMAKE_INSTALL_PREFIX=${SCOTCH_PREFIX}/install -DCMAKE_BUILD_TYPE=Release .. 2>&1 | tee cmake.out

cmake VERBOSE=1 -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_C_COMPILER=icc -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_BUILD_TYPE=Release .. 2>&1 | tee cmake.out

make VERBOSE=1 2>&1 | tee make.out
make install 2>&1 | tee install.log
make scotch 2>&1 | tee make_scotch.log
make ptscotch 2>&1 | tee make_ptscotch.log


# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
