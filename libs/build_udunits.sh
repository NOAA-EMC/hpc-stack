#!/bin/bash

set -eux

name="udunits"
version=${1:-${STACK_udunits_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

[[ ${STACK_udunits_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

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
    prefix=${UDUNITS_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export FFLAGS="${STACK_FFLAGS:-} ${STACK_udunits_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_udunits_CFLAGS:-} -fPIC"
export FCFLAGS="$FFLAGS"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url=ftp://ftp.unidata.ucar.edu/pub/udunits/$software.tar.gz
[[ -d $software ]] || ( $WGET $url; tar xvf $software.tar.gz && rm -f $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ $enable_shared =~ [yYtT] ]] && shared_flags="" || shared_flags="--disable-shared --enable-static"

../configure --prefix=$prefix $shared_flags

make -j${NTHREADS:-4}
[[ "$MAKE_CHECK" = "YES" ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
