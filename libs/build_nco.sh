#!/bin/bash

set -ex

name="nco"
version=${1:-${STACK_nco_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  [[ -z $mpi ]] || module load hpc-$HPC_MPI
  module try-load zlib/${STACK_zlib_version}
  module try-load szip/${STACK_szip_version}
  module load hdf5/${STACK_hdf5_version}
  module load netcdf/${STACK_netcdf_version}
  module try-load udunits/${STACK_udunits_version}
  module list
  set -x
  enable_pnetcdf=$(nc-config --has-pnetcdf)
  set +x
    [[ $enable_pnetcdf =~ [yYtT] ]] && module load pnetcdf/${STACK_pnetcdf_version}
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"

  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
    prefix=${NCO_ROOT:-"/usr/local"}
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

export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

export F77=$FC
export FCFLAGS=$FFLAGS

#LDFLAGS1="-L$HDF5_ROOT/lib -lhdf5_hl -lhdf5"
#LDFLAGS2=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep AM_LDFLAGS | cut -d: -f2)
#LDFLAGS3=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "Extra libraries" | cut -d: -f2)
#if [[ ! -z $mpi ]]; then
#  [[ $enable_pnetcdf =~ [yYtT] ]] && LDFLAGS4="-L$PNETCDF_ROOT/lib -lpnetcdf"
#fi
#LDFLAGS5="-L$NETCDF_ROOT/lib -lnetcdf"
#export LDFLAGS="$LDFLAGS1 $LDFLAGS2 $LDFLAGS3 $LDFLAGS4 $LDFLAGS5"

gitURL="https://github.com/nco/nco.git"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

#../configure --prefix=$prefix \
#             --enable-doc=no \
#             --enable-netcdf4 \
#             --enable-shared=no \
#             NETCDF_INC=$NETCDF_ROOT/include \
#             NETCDF_LIB=$NETCDF_ROOT/lib

cmake .. \
  -DNETCDF_INCLUDE:PATH=$NETCDF_ROOT/include \
  -DNETCDF_LIBRARY:FILE=$NETCDF_ROOT/lib/libnetcdf.a \
  -DHDF5_LIBRARY:FILE=$HDF5_ROOT/lib/libhdf5.a \
  -DHDF5_HL_LIBRARY:FILE=$HDF5_ROOT/lib/libhdf5_hl.a \
  -DZLIB_LIBRARY:FILE=$ZLIB_ROOT/lib/libz.a \
  -DSZIP_LIBRARY:FILE=$SZIP_ROOT/lib/libsz.a \
  -DCMAKE_INSTALL_PREFIX=$prefix

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
