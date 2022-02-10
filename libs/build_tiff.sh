#!/bin/bash

set -eux

name="tiff"
version=${1:-${STACK_tiff_version}}

[[ ${STACK_tiff_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

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
    prefix=${TIFF_ROOT:-"/usr/local"}
fi

#export CC=$SERIAL_CC
#export CFLAGS="${STACK_CFLAGS:-} ${STACK_tiff_CFLAGS:-} -fPIC"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://gitlab.com/lib${name}/lib${name}.git"
[[ -d $software ]] || ( git clone $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
sourceDir=$PWD
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=$prefix
cd build
#
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make install
# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
