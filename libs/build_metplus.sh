#!/bin/bash                                                                                                                              

set -eux

name="metplus"
version=${1:-${STACK_metplus_version}}

cd  ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
software="v"$version
pkg_name=$name-$version
url="https://github.com/dtcenter/METplus/archive/$software.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ -d $pkg_name ]] && cd $$pkg_name || ( echo "$pkg_name does not exist, ABORT!"; exit 1 )


# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then

    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module load nco
    module load grib_util
    module load met
    set -x
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
	    || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi	
else

    prefix=${NETCDF_ROOT:-"/usr/local"}

fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
curr_dir=$(pwd)
export PATH=${curr_dir}/ush:${PATH}
