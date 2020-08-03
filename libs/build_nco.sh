#!/bin/bash

set -ex

name="nco"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  [[ -z $mpi ]] || module load hpc-$HPC_MPI 
  module try-load szip
  module load hdf5
  module load netcdf
  module try-load udunits
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"

  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
    prefix=${NCO_ROOT:-"/usr/local"}
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

export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

export F77=$FC
export FCFLAGS=$FFLAGS

export LDFLAGS="-L$NETCDF_ROOT/lib -L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

gitURL="https://github.com/nco/nco.git"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix --enable-doc=no

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
