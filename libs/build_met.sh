#!/bin/bash    

set -eux

name="met"
version=${1:-${STACK_met_version}}
release_date=${2:-${STACK_met_release_date}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    [[ -z $mpi ]] || module load hpc-$HPC_MPI
    module load hpc-$HPC_PYTHON
    module load bufr
    module load zlib
    module load jasper
    module load png
    module load g2c
    module load gsl
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

    prefix=${MET_ROOT:-"/usr/local"}

fi

export MET_BASE=$prefix/share/met

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
export FFLAGS="${STACK_FFLAGS:-} ${STACK_met_FFLAGS:-}"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_met_CFLAGS:-}"

export MET_NETCDF=${NETCDF_ROOT}
export MET_HDF5=${HDF5_ROOT}
export MET_BUFRLIB=${bufr_ROOT}/lib
export MET_GRIB2CLIB=${g2c_ROOT}/lib
export MET_GRIB2CINC=${g2c_ROOT}/include
export MET_GSL=${GSL_ROOT}
export BUFRLIB_NAME=-lbufr_4
export GRIB2CLIB_NAME=-lg2c
export LIB_JASPER=${JASPER_ROOT}/lib64
export LIB_LIBPNG=${PNG_ROOT}/lib64
export LIB_Z=${ZLIB_ROOT}/lib

LDFLAGS1="-Wl,--disable-new-dtags"
LDFLAGS2="-Wl,-rpath,${MET_NETCDF}/lib:${MET_HDF5}/lib:${MET_BUFRLIB}"
#LDFLAGS3="-Wl,-rpath,${MET_GRIB2CLIB}:${MET_PYTHON}/lib:${MET_GSL}/lib"
LDFLAGS3="-Wl,-rpath,${MET_GRIB2CLIB}:${MET_GSL}/lib"
LDFLAGS4="-L${LIB_JASPER} -L${MET_HDF5}/lib -L${LIB_LIBPNG} -L${LIB_Z}"
LDFLAGS5="-L${I_MPI_ROOT}/lib64"
if [[ -z $mpi ]]; then
  export LDFLAGS="${LDFLAGS1:-} ${LDFLAGS2:-} ${LDFLAGS3:-} ${LDFLAGS4:-}"
else
  export LDFLAGS="${LDFLAGS1:-} ${LDFLAGS2:-} ${LDFLAGS3:-} ${LDFLAGS4:-} ${LDFLAGS5:-}"
fi
  export LIBS="-lhdf5_hl -lhdf5 -lz"


export CFLAGS+="-D__64BIT__"
export CXXFLAGS+="-D__64BIT__"

cd  ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
software=$name-$version.$release_date
pkg_name=$name-$version
url="https://github.com/dtcenter/MET/releases/download/v$version/$software.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $pkg_name ]] && cd $pkg_name || ( echo "$pkg_name does not exist, ABORT!"; exit 1 )

set +x

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}/${pkg_name}
curr_dir=$(pwd)

echo "MET Configuration settings..."
printenv | egrep "^MET_" | sed -r 's/^/export /g'
echo "LDFLAGS = ${LDFLAGS}"

#echo "./configure --prefix=$prefix BUFRLIB_NAME=${BUFRLIB_NAME} GRIB2CLIB_NAME=${GRIB2CLIB_NAME} --enable-grib2 --enable-python"
./configure --prefix=$prefix BUFRLIB_NAME=${BUFRLIB_NAME} GRIB2CLIB_NAME=${GRIB2CLIB_NAME} --enable-grib2 --enable-python

set -x

ret=$?
if [ $ret != 0 ]; then
    echo "configure returned with non-zero ($ret) status"
    exit 1
fi

echo "make > make.log 2>&1"
make > make.log 2>&1
ret=$?
if [ $ret != 0 ]; then
    echo "make returned with non-zero ($ret) status"
    exit 1
fi

echo "make install > make_install.log 2>&1"
$SUDO make install > make_install.log 2>&1
ret=$?
if [ $? != 0 ]; then
    echo "make install returned with non-zero ($ret) status"
    exit 1
fi

echo "make test > make_test.log 2>&1"
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
make test > make_test.log 2>&1
ret=$?
if [ $? != 0 ]; then
    echo "make test returned with non-zero ($ret) status"
    exit 1
fi

export PATH=${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}/${pkg_name}:${PATH}
echo "Finished compiling at `date`"
