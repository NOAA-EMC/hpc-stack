#!/bin/bash

set -ex

name="pio"
version=$1

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module load hpc-$HPC_MPI 
    module try-load cmake
    module load netcdf
    module load pnetcdf
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
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=ParallelIO
branch=pio$(echo $version | sed -e 's/\./_/g')
[[ -d $software ]] || git clone https://github.com/NCAR/$software
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch
git checkout $branch
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
export CMAKE_INCLUDE_PATH=$MPI_Fortran_INCLUDE_PATH #Find MPI is broken in PIO GPTL MPIMOD_PATH must be found at this prefix
cmake -DNetCDF_C_PATH=$NETCDF -DNetCDF_Fortran_PATH=$NETCDF -DPnetCDF_PATH=$PNETCDF -DHDF5_PATH=$HDF5_ROOT -DCMAKE_INSTALL_PREFIX=$prefix -DPIO_USE_MALLOC=ON -DCMAKE_VERBOSE_MAKEFILE=1 -DPIO_ENABLE_TIMING=OFF ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
