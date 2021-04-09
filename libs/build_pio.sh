#!/bin/bash

set -eux

name="pio"
version=${1:-${STACK_pio_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

[[ ${STACK_pio_enable_pnetcdf:-} =~ [yYtT] ]] && enable_pnetcdf=YES || enable_pnetcdf=NO
[[ ${STACK_pio_enable_gptl:-} =~ [yYtT] ]] && enable_gptl=YES || enable_gptl=NO

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module load hpc-$HPC_MPI
    module try-load cmake
    module load szip
    module load hdf5
    [[ $enable_pnetcdf =~ [yYtT] ]] && module load pnetcdf
    module load netcdf
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${PIO_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX

export F9X=$FC
export FFLAGS="${STACK_FFLAGS:-} ${STACK_pio_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_pio_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_pio_CXXFLAGS:-} -fPIC"
export FCFLAGS="$FFLAGS"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
if [[ "$version" = "2.5.1" ]]; then
  branch=pio_$(echo $version | sed -e 's/\./_/g')
else
  branch=pio$(echo $version | sed -e 's/\./_/g')
fi
[[ -f $software.tar.gz ]] || $WGET https://github.com/NCAR/ParallelIO/releases/download/$branch/${software}.tar.gz

tar -xf ${software}.tar.gz


[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

# e.g. -L$ZLIB_ROOT/lib
AM_LDFLAGS=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep AM_LDFLAGS | cut -d: -f2)
# e.g. -lz -ldl -lm
EXTRA_LIBS=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "Extra libraries" | cut -d: -f2)

export HDF5_LDFLAGS="-L$HDF5_ROOT/lib -lhdf5_hl -lhdf5"
export HDF5_LIBS="-lhdf5_hl -lhdf5"
export NETCDF_LDFLAGS="-L$NETCDF_ROOT/lib"

export CPPFLAGS="-I$NETCDF_ROOT/include"

if [[ $enable_pnetcdf =~ [yYtT] ]]; then
    PNETCDF_LDFLAGS="-L$PNETCDF_LIBRARIES"
    PNETCDF_FLAGS=""
else
    PNETCDF_LDFLAGS=""
    PNETCDF_FLAGS="--disable-pnetcdf"
fi

if [[ $enable_gptl =~ [yYtT] ]]; then
    TIMING_FLAGS="--enable-timing"
else
    TIMING_FLAGS=""
fi

export LDFLAGS="$PNETCDF_LDFLAGS $NETCDF_LDFLAGS $HDF5_LDFLAGS $AM_LDFLAGS"
export LIBS="$HDF5_LIBS $EXTRA_LIBS"

../configure --prefix=$prefix \
             --enable-fortran \
             $TIMING_FLAGS $PNETCDF_FLAGS
             

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
