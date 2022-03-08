#!/bin/bash

set -eux

name="wgrib2"
version=${1:-${STACK_wgrib2_version}}

software=$name-$version

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
install_as=${STACK_wgrib2_install_as:-${version}}

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module list
    set -x
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$install_as"
    if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
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

# The Jasper inside of wgrib2 does not build with Clang on macOS
# Implicit function declaration error and no way to pass flags to suppress it.
host=$(uname -s)
if [[ "$host" == "Darwin" ]]; then
    if [[ `$CC --version` == *"clang"* ]]; then
        echo "Warning: The Jasper contained in wgrib2 does not build with Clang on macOS"
        export STACK_wgrib2_jasper=0
    fi
fi

if [[ $($CC --version | grep Intel) ]]; then
    export COMP_SYS=intel_linux
fi

# Wgrib2 uses an in-source build. Clean before starting.
make clean
make deep-clean

# Edit makefile with options or defaults
sed -i'.backup' "s:^USE_NETCDF3=.*:USE_NETCDF3=${STACK_wgrib2_netcdf3:-1}:" makefile
sed -i'.backup' "s:^USE_NETCDF4=.*:USE_NETCDF4=${STACK_wgrib2_netcdf4:-0}:" makefile
sed -i'.backup' "s:^USE_REGEX=.*:USE_REGEX=${STACK_wgrib2_negex:-1}:" makefile
sed -i'.backup' "s:^USE_TIGGE=.*:USE_TIGGE=${STACK_wgrib2_tigge:-1}:" makefile
sed -i'.backup' "s:^USE_IPOLATES=.*:USE_IPOLATES=${STACK_wgrib2_ipolates:-3}:" makefile
sed -i'.backup' "s:^USE_SPECTRAL=.*:USE_SPECTRAL=${STACK_wgrib2_spectral:-0}:" makefile
sed -i'.backup' "s:^USE_UDF=.*:USE_AEC=${STACK_wgrib2_udf:-0}:" makefile
sed -i'.backup' "s:^USE_JASPER=.*:USE_JASPER=${STACK_wgrib2_jasper:-1}:" makefile
sed -i'.backup' "s:^USE_OPENMP=.*:USE_OPENMP=${STACK_wgrib2_openmp:-1}:" makefile
sed -i'.backup' "s:^MAKE_FTN_API=.*:MAKE_FTN_API=${STACK_wgrib2_ftn_api:-1}:" makefile
sed -i'.backup' "s:^USE_G2CLIB=.*:USE_G2CLIB=${STACK_wgrib2_g2clib:-0}:" makefile
sed -i'.backup' "s:^USE_PNG=.*:USE_PNG=${STACK_wgrib2_png:-1}:" makefile
sed -i'.backup' "s:^USE_AEC=.*:USE_AEC=${STACK_wgrib2_aec:-1}:" makefile

# Fix openmp flag in older version of wgrib2. Intel compilers no longer accept -openmp.
sed -i'.backup' "s:-openmp:-qopenmp:" makefile

make

# Wgrib2 does not provide a 'make install'
$SUDO mkdir -p ${prefix}
$SUDO mkdir -p ${prefix}/bin

$SUDO cp wgrib2/wgrib2 $prefix/bin

# Build wgrib2 library with all settings off
if [[ ${STACK_wgrib2_lib:-n} =~ [yYtT] ]]; then
    make clean
    make deep-clean

    $SUDO mkdir -p ${prefix}/lib
    $SUDO mkdir -p ${prefix}/include

    sed -i'.backup' "s:^USE_NETCDF3=.*:USE_NETCDF3=0:" makefile
    sed -i'.backup' "s:^USE_NETCDF4=.*:USE_NETCDF4=0:" makefile
    sed -i'.backup' "s:^USE_REGEX=.*:USE_REGEX=1:" makefile
    sed -i'.backup' "s:^USE_TIGGE=.*:USE_TIGGE=1:" makefile
    sed -i'.backup' "s:^USE_IPOLATES=.*:USE_IPOLATES=0:" makefile
    sed -i'.backup' "s:^USE_SPECTRAL=.*:USE_SPECTRAL=0:" makefile
    sed -i'.backup' "s:^USE_UDF=.*:USE_AEC=0:" makefile
    sed -i'.backup' "s:^USE_JASPER=.*:USE_JASPER=0:" makefile
    sed -i'.backup' "s:^USE_OPENMP=.*:USE_OPENMP=0:" makefile
    sed -i'.backup' "s:^MAKE_FTN_API=.*:MAKE_FTN_API=1:" makefile
    sed -i'.backup' "s:^USE_G2CLIB=.*:USE_G2CLIB=0:" makefile
    sed -i'.backup' "s:^USE_PNG=.*:USE_PNG=0:" makefile
    sed -i'.backup' "s:^USE_AEC=.*:USE_AEC=0:" makefile

    make lib

    $SUDO cp lib/libwgrib2.a ${prefix}/lib
    $SUDO cp lib/wgrib2api.mod lib/wgrib2lowapi.mod ${prefix}/include

    # Stage CMake package config, fill-in the version, and install
    rm -rf cmake
    mkdir cmake
    cp -r ${HPC_STACK_ROOT}/cmake/wgrib2 ./cmake
    sed -i'.backup' -e "s:@WGRIB2_VERSION@:${version}:" ./cmake/wgrib2/wgrib2-config-version.cmake
    rm ./cmake/wgrib2/wgrib2-config-version.cmake.backup
    $SUDO cp -r cmake ${prefix}/lib
fi

# generate modulefile from template
modpath=compiler
$MODULES && update_modules $modpath $name $install_as
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
