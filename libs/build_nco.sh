#!/bin/bash

set -eux

name="nco"
version=${1:-${STACK_nco_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

URL="https://github.com/nco/nco.git"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

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
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
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

export FFLAGS="${STACK_FFLAGS:-} ${STACK_nco_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_nco_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_nco_CXXFLAGS:-} -fPIC"

export F77=$FC
export FCFLAGS=$FFLAGS

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
NETCDF_LIBS="-lnetcdf"

export LDFLAGS="${PNETCDF_LDFLAGS:-} ${NETCDF_LDFLAGS:-} ${HDF5_LDFLAGS:-} ${AM_LDFLAGS:-}"
export LIBS="${PNETCDF_LIBS:-} ${NETCDF_LIBS:-} ${HDF5_LIBS:-} ${EXTRA_LIBS:-}"

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

nc_ver=$(nc-config --version)
major_ver=$(echo $nc_ver | cut -d' ' -f2 | cut -d. -f1)
if [[ $major_ver == "4" ]]; then
    # Prevents duplicate symbols
    # See http://nco.sourceforge.net/build_hints.shtml
    CPPFLAGS="-DHAVE_NETCDF4_H"
fi

../configure --prefix=$prefix \
             --enable-doc=no \
             --enable-netcdf4 \
             --enable-shared=no \
	     --enable-ncap2=no \
             NETCDF_INC=$NETCDF_ROOT/include \
             NETCDF_LIB=$NETCDF_ROOT/lib

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
