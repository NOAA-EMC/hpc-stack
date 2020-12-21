#!/bin/bash                                                                                                                              

set -eux

name="met"
version=${1:-${STACK_met_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
    
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
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
LDFLAGS4="-L${LIB_JASPER} -L${MET_HDF5}/lib"
export LDFLAGS="${LDFLAGS1:-} ${LDFLAGS2:-} ${LDFLAGS3:-} ${LDFLAGS4:-}"
export LIBS="${LIBS} -lhdf5_hl -lhdf5 -lz"

export CFLAGS+="-D__64BIT__"
export CXXFLAGS+="-D__64BIT__"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
curr_dir=$(pwd)

