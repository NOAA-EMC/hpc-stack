#!/bin/bash

set -eux

name="gsl"
version=${1:-${STACK_gsl_version}}

compiler=$(echo $HPC_COMPILER | sed 's:/:-:g')
mpi=$(echo $HPC_MPI | sed 's:/:-:g')

if $MODULES; then
    set + x
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
    prefix=${GSL_ROOT:-"/usr/local"}
fi


export CC=$SERIAL_CC
eval cflags="\${STACK_${name}_CFLAGS:-}"
export CFLAGS="${STACK_CFLAGS:-} $cflags -fPIC -w"

software=$name-$version

url="ftp://ftp.gnu.org/gnu/gsl/${software}.tar.gz"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

modpath=compiler
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
