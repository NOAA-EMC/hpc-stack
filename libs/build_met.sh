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

#export MET_PYTHON=/usrx/local/prod/packages/python/3.6.3/
#export MET_PYTHON_CC=-I/usrx/local/prod/packages/python/3.6.3/include/python3.6m\ -I/usrx/local/prod/packages/python/3.6.3/include/python3.6m
#export MET_PYTHON_LD=-L/usrx/local/prod/packages/python/3.6.3/lib/\ -lpython3.6m\ -lpthread\ -ldl\ -lutil\ -lm\ -Xlinker\ -export-dynamic
export MET_NETCDF=${NetCDF_LIBRARIES}
export MET_HDF5=${HDF5_LIBRARIES}
#export MET_BUFRLIB=/gpfs/dell1/nco/ops/nwprod/lib/bufr/v11.3.0/ips/18.0.1
#export MET_GRIB2CLIB=/gpfs/dell1/nco/ops/nwprod/lib/g2c/v1.5.0/ips/18.0.1
#export MET_GRIB2CINC=/gpfs/dell1/nco/ops/nwprod/lib/g2c/v1.5.0/src
#export MET_GSL=$GSL_ROOT
#export BUFRLIB_NAME=-lbufr_v11.3.0_4_64
#export GRIB2CLIB_NAME=-lg2c_v1.5.0_4
#export LIB_JASPER=/usrx/local/prod/packages/gnu/4.8.5/jasper/1.900.1/lib
#export LIB_LIBPNG=/usrx/local/prod/packages/gnu/4.8.5/libpng/1.2.59/lib
#export LIB_Z=/usrx/local/prod/packages/ips/18.0.1/zlib/1.2.11/lib
export SET_D64BIT=TRUE

LDFLAGS1="-Wl,--disable-new-dtags"
LDFLAGS2="-Wl,-rpath,"

