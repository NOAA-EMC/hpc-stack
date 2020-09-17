#!/bin/bash

# Building cmake from source is sometimes preferable to package installs
# because it allows you to get the most up-to-date versions and it
# allows you to place it into a module context so you can experiment
# with different versions

set -eux

name="cmake"
version=${1:-${STACK_cmake_version}}

if $MODULES; then
  module load hpc-$HPC_COMPILER
  module list

  prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; rm -rf $prefix; mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${CMAKE_ROOT:-"/usr/local"}
fi

software=$name-$version
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
url="https://cmake.org/files/v${version%.*}/$software.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export FC=$SERIAL_FC

./bootstrap --prefix=$prefix
make -j${NTHREADS:-4}
make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
