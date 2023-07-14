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
  [[ -z $mpi ]] || module load hpc-$HPC_MPI
  module list
  set -x

  install_as=${STACK_scotch_install_as:-${version}}
  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$install_as"
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

if [[ ! -z $mpi ]]; then
  export FC=$MPI_FC
  export CC=$MPI_CC
  export CXX=$MPI_CXX
else
  export FC=$SERIAL_FC
  export CC=$SERIAL_CC
  export CXX=$SERIAL_CXX
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
cmake VERBOSE=1 -DCMAKE_C_FLAGS="-std=gnu11" -DCMAKE_Fortran_COMPILER=${FC} -DCMAKE_C_COMPILER=${CC} -DMAKE_CXX_COMPILER=${CXX}   -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release -DTHREADS=OFF -DMPI_THREAD_MULTIPLE=OFF ..

make VERBOSE=1
make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $id
echo $name $id $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
