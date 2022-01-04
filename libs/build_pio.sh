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
    module try-load szip
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

URL=https://github.com/NCAR/ParallelIO
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git checkout $branch

# These repositories are used internally by PIO. Download them so DOWNLOAD_ONLY option works.
[[ -d CMake_Fortran_utils ]] || git clone https://github.com/CESM-Development/CMake_Fortran_utils
[[ -d genf90 ]] || git clone https://github.com/PARALLELIO/genf90.git
CMAKE_FLAGS="-DUSER_CMAKE_MODULE_PATH=`pwd`/CMake_Fortran_utils -DGENF90_PATH=`pwd`/genf90"

[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d build ]] && rm -rf build
mkdir -p build && cd build


[[ $enable_pnetcdf =~ [yYtT] ]] && CMAKE_FLAGS+=" -DWITH_PNETCDF=ON -DPnetCDF_PATH=$PNETCDF" \
                                || CMAKE_FLAGS+=" -DWITH_PNETCDF=OFF"
[[ $enable_gptl =~ [yYtT] ]] && CMAKE_FLAGS+=" -DPIO_ENABLE_TIMING=ON" \
                             || CMAKE_FLAGS+=" -DPIO_ENABLE_TIMING=OFF"


cmake ..\
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DNetCDF_PATH=${NETCDF_ROOT:-} \
  -DHDF5_PATH=${HDF5_ROOT:-} \
  -DCMAKE_VERBOSE_MAKEFILE=1 \
  $CMAKE_FLAGS


VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make test
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
