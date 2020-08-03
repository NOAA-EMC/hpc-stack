#!/bin/bash

set -ex

name="nccmp"
version=$1

software=$name-$version

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

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${NCCMP_ROOT:-"/usr/local"}
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

export CFLAGS="-fPIC"
export LDFLAGS="-L$NETCDF_ROOT/lib -L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

url="https://gitlab.com/remikz/nccmp/-/archive/$version/${software}.tar.gz"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Enable header pad comparison, if netcdf-c src directory exists!
[[ -d "netcdf-c-$NETCDF_VERSION" ]] && extra_confs="--with-netcdf=$PWD/netcdf-c-$NETCDF_VERSION" || extra_confs=""

[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix $extra_confs

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
