#!/bin/bash

set -eux

name="lapack"
version=${1:-${STACK_lapack_version}}

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
    prefix=${LAPACK_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export FFLAGS="${STACK_lapack_FFLAGS} -fPIC"
export CFLAGS="${STACK_lapack_CFLAGS} -fPIC"
export CXXFLAGS="${STACK_lapack_CXXFLAGS} -fPIC"
export FCFLAGS="$FFLAGS"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
url="http://www.netlib.org/lapack/$software.tgz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tgz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

# Add CMAKE_INSTALL_LIBDIR to make sure it will be installed under lib not lib64
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR:PATH=$prefix/lib \
      -DCMAKE_Fortran_COMPILER=$SERIAL_FC -DCMAKE_Fortran_FLAGS=$FCFLAGS ..

VERBOSE="$MAKE_VERBOSE" make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
VERBOSE="$MAKE_VERBOSE" $SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
