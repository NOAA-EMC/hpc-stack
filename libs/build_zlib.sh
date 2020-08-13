#!/bin/bash

set -ex

name="zlib"
version=${1:-${STACK_zlib_version}}

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
    prefix=${ZLIB_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export FCFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
#url=http://www.zlib.net/$software.tar.gz
#[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
gitURL=https://github.com/madler/zlib
[[ -d $software ]] || ( git clone -b v$version $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

outOfSource="1.2.10"
if [ "$(printf '%s\n' "$outOfSource" "$version" | sort -V | head -n1)" = "$outOfSource" ]; then
  [[ -d build ]] && rm -rf build
  mkdir -p build && cd build
  ../configure --prefix=$prefix
else
  ./configure --prefix=$prefix
fi

make -j${NTHREADS:-4}
[[ "$MAKE_CHECK" = "YES" ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
