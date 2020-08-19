#!/bin/bash

set -eux

name="nccmp"
version=${1:-${STACK_nccmp_version}}

software=$name-$version

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

url="https://gitlab.com/remikz/nccmp/-/archive/$version/${software}.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz && rm -f $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

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
    prefix=${NCCMP_ROOT:-"/usr/local"}
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

export CFLAGS="${STACK_nccmp_CFLAGS:-} -fPIC"
LDFLAGS1="-L$HDF5_ROOT/lib -lhdf5_hl -lhdf5"
LDFLAGS2=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep AM_LDFLAGS | cut -d: -f2)
LDFLAGS3=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "Extra libraries" | cut -d: -f2)
if [[ ! -z $mpi ]]; then
  [[ $enable_pnetcdf =~ [yYtT] ]] && LDFLAGS4="-L$PNETCDF_ROOT/lib -lpnetcdf"
fi
LDFLAGS5="-L$NETCDF_ROOT/lib -lnetcdf"
export LDFLAGS="${LDFLAGS1:-} ${LDFLAGS2:-} ${LDFLAGS3:-} ${LDFLAGS4:-} ${LDFLAGS5:-}"

# Enable header pad comparison, if netcdf-c src directory exists!
[[ -d "netcdf-c-${NETCDF_VERSION:-}" ]] && netcdf_src="$PWD/netcdf-c-$NETCDF_VERSION"
[[ -d "netcdf-c-${NETCDF_VERSION:-}" ]] && extra_confs="--with-netcdf=$netcdf_src"

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

#../configure --prefix=$prefix $extra_confs
cmake .. \
  -DBUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DNETCDF_INC_DIR=$NETCDF_ROOT/include \
  -DNETCDF_LIB_PATH=$NETCDF_ROOT/lib/libnetcdf.a \
  -DWITH_NETCDF=${netcdf_src:-}

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
