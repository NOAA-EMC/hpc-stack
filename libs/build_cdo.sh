#!/bin/bash

set -eux

name="cdo"
version=${1:-${STACK_cdo_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  [[ -z $mpi ]] || module load hpc-$HPC_MPI
  module try-load zlib
  module try-load szip
  module load hdf5
  module load netcdf
  module try-load udunits
  module list
  set -x
  enable_pnetcdf=$(nc-config --has-pnetcdf)
  set +x
    [[ $enable_pnetcdf =~ [yYtT] ]] && module load pnetcdf
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"

  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${CDO_ROOT:-"/usr/local"}
  enable_pnetcdf=$(nc-config --has-pnetcdf)
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

export FFLAGS="${STACK_FFLAGS:-} ${STACK_cdo_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_cdo_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_cdo_CXXFLAGS:-} -fPIC"

export F77=$FC
export FCFLAGS=$FFLAGS

HDF5_LDFLAGS="-L$HDF5_ROOT/lib"
HDF5_LIBS="-lhdf5_hl -lhdf5"

AM_LDFLAGS=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep AM_LDFLAGS | cut -d: -f2)
EXTRA_LIBS=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "Extra libraries" | cut -d: -f2)

if [[ ! -z $mpi ]]; then
  [[ $enable_pnetcdf =~ [yYtT] ]] && LDFLAGS4="-L$PNETCDF_ROOT/lib -lpnetcdf"
fi
NETCDF_LDFLAGS="-L$NETCDF_ROOT/lib"
NETCDF_LIBS="-lnetcdf"

export LDFLAGS="${NETCDF_LDFLAGS:-} ${HDF5_LDFLAGS:-} ${AM_LDFLAGS:-}"
export LIBS="${NETCDF_LIBS:-} ${HDF5_LIBS:-} ${EXTRA_LIBS:-}"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

case $version in
  1.9.9 )
    URL="https://code.mpimet.mpg.de/attachments/download/23323/cdo-1.9.9.tar.gz"
  ;;
  1.9.8 )
    URL="https://code.mpimet.mpg.de/attachments/download/20826/cdo-1.9.8.tar.gz"
  ;;
  1.9.7.1 )
    URL="https://code.mpimet.mpg.de/attachments/download/20124/cdo-1.9.7.1.tar.gz"
  ;;
  1.9.6 )
    URL="https://code.mpimet.mpg.de/attachments/download/19299/cdo-1.9.6.tar.gz"
  ;;
  * )
    echo "Try using CDO version 1.9.6 and above, ABORT!"
    exit 1
  ;;
esac

software=$name-$version
[[ -d $software ]] || ( $WGET $URL; tar -xzf $software.tar.gz && rm -f $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix \
             --with-hdf5=$HDF5_ROOT \
             --with-netcdf=$NETCDF_ROOT

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
