#!/bin/bash

set -eux

name="madis"
version=${1:-${STACK_madis_version}}

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
  module list
  set -x
  enable_pnetcdf=$(nc-config --has-pnetcdf)
  set +x
    [[ $enable_pnetcdf =~ [yYtT] ]] && module load pnetcdf
  set -x
  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${MADIS_ROOT:-"/usr/local"}
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

export F77=$FC
export FFLAGS="${STACK_FFLAGS:-} ${STACK_madis_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_madis_CFLAGS:-} -fPIC"

HDF5_LDFLAGS="-L$HDF5_ROOT/lib"
HDF5_LIBS="-lhdf5_hl -lhdf5"

AM_LDFLAGS=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep AM_LDFLAGS | cut -d: -f2)
EXTRA_LIBS=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "Extra libraries" | cut -d: -f2)

if [[ ! -z $mpi ]]; then
  if [[ $enable_pnetcdf =~ [yYtT] ]]; then
    PNETCDF_LDFLAGS="-L$PNETCDF_ROOT/lib"
    PNETCDF_LIBS="-lpnetcdf"
  fi
fi

NETCDF_LDFLAGS="-L$NETCDF_ROOT/lib"
NETCDF_LIBS="-lnetcdff -lnetcdf"

export LDFLAGS="${PNETCDF_LDFLAGS:-} ${NETCDF_LDFLAGS:-} ${HDF5_LDFLAGS} ${AM_LDFLAGS:-}"
export LIBS="${PNETCDF_LIBS:-} ${NETCDF_LIBS} ${HDF5_LIBS} ${EXTRA_LIBS:-}"
export CPPFLAGS="-I${NETCDF_ROOT}/include"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://madis-data.ncep.noaa.gov/source/$software.tar.gz"
[[ -f $software.tar.gz ]] || ( $WGET $URL )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
rm -rf $software && mkdir -p $software && cd $software
tar -xf ../$software.tar.gz

# cd into src/ directory where the makefile is
cd src

# Use sed to comment out the following hard-wired assignments in makefile
# NETCDF_LIB, NETCDF_INC
# FC, FFLAGS, LDFLAGS

sed -i -e 's/NETCDF_LIB=/#NETCDF_LIB/g' makefile
sed -i -e 's/NETCDF_INC=/#NETCDF_INC/g' makefile
sed -i -e 's/FC=/#FC/g'                 makefile
sed -i -e 's/FFLAGS=/#FFLAGS/g'         makefile
sed -i -e 's/LDFLAGS=/#LDFLAGS/g'       makefile

export NETCDF_LIB=$LIBS
export NETCDF_INC="${NETCDF_ROOT}/include"

# make in MADIS does not support parallel build
VERBOSE=$MAKE_VERBOSE make #-j${NTHREADS:-4}

# `make` builds and installs in predefined paths hard-wired in makefile
# ../bin/ ../include/ ../lib/
# ../doc/ and ../static/ are already populated prior to build
# move them to $prefix
cd ..
$SUDO mkdir -p     $prefix/bin
$SUDO mkdir -p     $prefix/include
$SUDO mkdir -p     $prefix/lib
$SUDO mkdir -p     $prefix/doc
$SUDO mkdir -p     $prefix/static

$SUDO mv bin/*     $prefix/bin/
$SUDO mv include/* $prefix/include/
$SUDO mv lib/*     $prefix/lib/
$SUDO mv doc/*     $prefix/doc/
$SUDO mv static/*  $prefix/static/

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
