#!/bin/bash

set -ex

name="netcdf"
c_version=$1
f_version=$2
cxx_version=$3

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
    [[ -z $mpi ]] || module load pnetcdf
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$c_version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${NETCDF_ROOT:-"/usr/local"}
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
export F9X=$FC
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC -std=c++11"
export FCFLAGS="$FFLAGS"

gitURLroot="https://github.com/Unidata"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
curr_dir=$(pwd)

export LDFLAGS="-L$HDF5_ROOT/lib -L$SZIP_ROOT/lib"

cd $curr_dir

##################################################
# Download only

if [[ ${DOWNLOAD_ONLY} =~ [yYtT] ]]; then

    version=$c_version
    software=$name-"c"-$version
    [[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-c.git $software )

    version=$f_version
    software=$name-"fortran"-$version
    [[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-fortran.git $software )

    version=$cxx_version
    software=$name-"cxx4"-$version
    [[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-cxx4.git $software )

    exit 0

fi

##################################################

set +x
echo "################################################################################"
echo "BUILDING NETCDF-C"
echo "################################################################################"
set -x

version=$c_version
software=$name-"c"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-c.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ -z $mpi ]] || extra_conf="--enable-pnetcdf --enable-parallel-tests"
../configure --prefix=$prefix --enable-netcdf-4 $extra_conf

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

export LDFLAGS+=" -L$prefix/lib"
export CFLAGS+=" -I$prefix/include"
export CXXFLAGS+=" -I$prefix/include"

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $c_version \
         || echo $software >> ${HPC_STACK_ROOT}/hpc-stack-contents.log

set +x
echo "################################################################################"
echo "BUILDING NETCDF-Fortran"
echo "################################################################################"

# Load netcdf-c before building netcdf-fortran
$MODULES && module load netcdf

set -x

cd $curr_dir

version=$f_version
software=$name-"fortran"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-fortran.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix --enable-netcdf-4 $extra_conf

#VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE make -j1 #NetCDF-Fortran-4.5.2 & intel/20 have a linker bug if built with j>1
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

cd $curr_dir

$MODULES || echo $software >> ${HPC_STACK_ROOT}/hpc-stack-contents.log

set +x
echo "################################################################################"
echo "BUILDING NETCDF-CXX"
echo "################################################################################"
set -x

version=$cxx_version
software=$name-"cxx4"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-cxx4.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

$MODULES || echo $software >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
