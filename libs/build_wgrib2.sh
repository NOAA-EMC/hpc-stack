#!/bin/bash

set -eux

name="wgrib2"
version=${1:-${STACK_wgrib2_version}}

software=$name-$version

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module list
    set -x
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
            || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${WGRIB2_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

URL="https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz.v${version}"

[[ -d $software ]] || ( $WGET $URL; tar -xf wgrib2.tgz.v${version} )
# wgrib2 is untarred as 'grib2'. Give a name with version.
[[ -d $software ]] || mkdir $software && tar -xf wgrib2.tgz.v${version} -C $software --strip-components 1
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

case $COMPILER in
  intel|ips )
    export COMP_SYS=intel_linux
    ;;
  gnu|gcc|clang )
    if [[ "$host" == "Darwin" ]]; then
    
    else
    
    fi
    ;;
  clang )
    
    ;;
  * )
    echo "Unsupported compiler = $COMPILER, ABORT!"; exit 1
    ;;
esac

# Wgrib2 uses an in-source build. Clean before starting.
make clean
make deep-clean

# Edit makefile with options or defaults
sed -i'' -e "s:^USE_NETCDF3=.*:USE_NETCDF3=${STACK_wgrib2_netcdf3:-1}:" makefile
sed -i'' -e "s:^USE_NETCDF4=.*:USE_NETCDF4=${STACK_wgrib2_netcdf4:-0}:" makefile
sed -i'' -e "s:^USE_REGEX=.*:USE_REGEX=${STACK_wgrib2_negex:-1}:" makefile
sed -i'' -e "s:^USE_TIGGE=.*:USE_TIGGE=${STACK_wgrib2_tigge:-1}:" makefile
sed -i'' -e "s:^USE_IPOLATES=.*:USE_IPOLATES=${STACK_wgrib2_ipolates:-3}:" makefile
sed -i'' -e "s:^USE_SPECTRAL=.*:USE_SPECTRAL=${STACK_wgrib2_spectral:-0}:" makefile
sed -i'' -e "s:^USE_UDF=.*:USE_AEC=${STACK_wgrib2_udf:-0}:" makefile
sed -i'' -e "s:^USE_JASPER=.*:USE_JASPER=${STACK_wgrib2_jasper:-1}:" makefile
sed -i'' -e "s:^USE_OPENMP=.*:USE_OPENMP=${STACK_wgrib2_openmp:-1}:" makefile
sed -i'' -e "s:^MAKE_FTN_API=.*:MAKE_FTN_API=${STACK_wgrib2_ftn_api:-1}:" makefile
sed -i'' -e "s:^USE_G2CLIB=.*:USE_G2CLIB=${STACK_wgrib2_g2clib:-0}:" makefile
sed -i'' -e "s:^USE_PNG=.*:USE_PNG=${STACK_wgrib2_png:-1}:" makefile
sed -i'' -e "s:^USE_AEC=.*:USE_AEC=${STACK_wgrib2_aec:-1}:" makefile

#VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
make

# Wgrib2 does not provide a 'make install'
$SUDO mkdir -p $prefix
$SUDO mkdir -p $prefix/lib
$SUDO mkdir -p $prefix/bin
$SUDO mkdir -p $prefix/include

$SUDO cp wgrib2/wgrib2 $prefix/bin

# Build wgrib2 library with all settings off
if [[ "${STACK_wgrib2_lib:-n}" =~ [yYtT] ]]; then
    make clean
    make deep-clean

    sed -i'' -e "s:^USE_NETCDF3=.*:USE_NETCDF3=0:" makefile
    sed -i'' -e "s:^USE_NETCDF4=.*:USE_NETCDF4=0:" makefile
    sed -i'' -e "s:^USE_REGEX=.*:USE_REGEX=1:" makefile
    sed -i'' -e "s:^USE_TIGGE=.*:USE_TIGGE=1:" makefile
    sed -i'' -e "s:^USE_IPOLATES=.*:USE_IPOLATES=0:" makefile
    sed -i'' -e "s:^USE_SPECTRAL=.*:USE_SPECTRAL=0:" makefile
    sed -i'' -e "s:^USE_UDF=.*:USE_AEC=0:" makefile
    sed -i'' -e "s:^USE_JASPER=.*:USE_JASPER=0:" makefile
    sed -i'' -e "s:^USE_OPENMP=.*:USE_OPENMP=0:" makefile
    sed -i'' -e "s:^MAKE_FTN_API=.*:MAKE_FTN_API=1:" makefile
    sed -i'' -e "s:^USE_G2CLIB=.*:USE_G2CLIB=0:" makefile
    sed -i'' -e "s:^USE_PNG=.*:USE_PNG=0:" makefile
    sed -i'' -e "s:^USE_AEC=.*:USE_AEC=0:" makefile

    #VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4} lib
    make lib

    $SUDO cp lib/libwgrib2.a lib/libwgrib2_api.a $prefix/lib
    $SUDO cp lib/*.mod $prefix/include
fi

# generate modulefile from template
modpath=compiler
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
