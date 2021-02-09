#!/bin/bash                                                                                                                              

set -eux

name="met"
version=${1:-${STACK_met_version}}
release_date==${2:-${STACK_met_release_date}}

cd  ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
software=$name-$version.$release_date
pkg_name=$name-$version
url="https://dtcenter.org/community-code/model-evaluation-tools-met/download/$software.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ -d $pkg_name ]] && cd $$pkg_name || ( echo "$pkg_name does not exist, ABORT!"; exit 1 )


# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
    
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module load python/3.6.3
    module load netcdf
    module load hdf5
    module load bufr
    module load g2c
    module load zlib
    module load jasper
    module load libpng
    module load gsl
    module list
    set -x
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
	    || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else

    prefix=${NETCDF_ROOT:-"/usr/local"}

fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export F77=$FC
export FFLAGS="${STACK_FFLAGS:-} ${STACK_met_FFLAGS:-}"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_met_CFLAGS:-}"

export MET_NETCDF=${NetCDF_LIBRARIES}
export MET_HDF5=${HDF5_LIBRARIES}
export MET_BUFRLIB=${$bufr_ROOT}/lib
export MET_GRIB2CLIB=${g2c_ROOT}/lib
export MET_GRIB2CINC=${g2c_ROOT}/include
export MET_GSL=${GSL_LIBRARIES}
export BUFRLIB_NAME=-lbufr_4
export GRIB2CLIB_NAME=-lg2c
export LIB_JASPER=${JASPER_LIBRARIES}
export LIB_LIBPNG=${PNG_LIBRARIES}
export LIB_Z=${ZLIB_LIBRARIES}
#export SET_D64BIT=TRUE

LDFLAGS1="-Wl,--disable-new-dtags"
LDFLAGS2="-Wl,-rpath,${MET_NETCDF}/lib:${MET_HDF5}/lib:${MET_BUFRLIB}"
LDFLAGS3="-Wl,-rpath,${MET_GRIB2CLIB},${MET_PYTHON}/lib:${MET_GSL}/lib"
LDFLAGS4="-L${LIB_JASPER} -L${MET_HDF5}/lib ${LIB_LIBPNG}"
export LDFLAGS="${LDFLAGS1:-} ${LDFLAGS2:-} ${LDFLAGS3:-} ${LDFLAGS4:-}"
export LIBS="${LIBS} -lhdf5_hl -lhdf5 -lz"

export CFLAGS+="-D__64BIT__"
export CXXFLAGS+="-D__64BIT__"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
curr_dir=$(pwd)
#export BIN_DIR_PATH=${HPC_STACK_ROOT}/exec
if [ -z ${BIN_DIR_PATH} ]; then
    BIN_DIR_PATH=${TEST_BASE}/bin
else
    BIN_DIR_PATH=${BIN_DIR_PATH}
fi

echo "MET Configuration settings..."
printenv | egrep "^MET_" | sed -r 's/^/export /g'
echo "LDFLAGS = ${LDFLAGS}"

echo "./configure --prefix=${HPC_STACK_ROOT} --bindir=${BIN_DIR_PATH} BUFRLIB_NAME=${BUFRLIB_NAME} GRIB2CLIB_NAME=${GRIB2CLIB_NAME} --enable-grib2 --enable-python"
./configure --prefix=${HPC_STACK_ROOT} --bindir=${BIN_DIR_PATH} BUFRLIB_NAME=${BUFRLIB_NAME} GRIB2CLIB_NAME=${GRIB2CLIB_NAME} --enable-grib2 --enable-python

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
make install > make_install.log 2>&1
ret=$?
if [ $? != 0 ]; then
    echo "make install returned with non-zero ($ret) status"
    exit 1
fi

echo "make test > make_test.log 2>&1"
make test > make_test.log 2>&1
ret=$?
if [ $? != 0 ]; then
    echo "make test returned with non-zero ($ret) status"
    exit 1
fi

export PATH=${BIN_DIR_PATH}:${PATH}
echo "Finished compiling at `date`"
