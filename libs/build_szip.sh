#!/bin/bash

set -ex

name="szip"
version=${1:-${STACK_szip_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

[[ ${STACK_szip_shared} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

# manage package dependencies here
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
    prefix=${SZIP_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export FC=$SERIAL_FC

export FFLAGS="${STACK_szip_FFLAGS} -fPIC"
export CFLAGS="${STACK_szip_CFLAGS} -fPIC"
export CXXFLAGS="${STACK_szip_CXXFLAGS} -fPIC"
export FCFLAGS="$FFLAGS"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url=https://support.hdfgroup.org/ftp/lib-external/szip/$version/src/$software.tar.gz
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz && rm -f $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ $enable_shared =~ [yYtT] ]] && shared_flags="" || shared_flags="--disable-shared --enable-static"

../configure --prefix=$prefix $shared_flags

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
