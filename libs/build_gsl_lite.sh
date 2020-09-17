#!/bin/bash

# This is a project to generate C++/Python bindings.
# Library is header-only, so there is no need to link to Python here.

set -eux

name="gsl-lite"
version=${1:-${STACK_gsl_lite_version}}

exit
# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load cmake
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${GSL_LITE_ROOT:-"/usr/local"}
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

gitURL="https://github.com/$name/$name"
software=$name-$version

[[ -d $software ]] || ( git clone -b "v$version" $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

[[ -d build ]] && rm -rf build
mkdir -p build && cd build
cmake .. \
      -DCMAKE_INSTALL_PREFIX=$prefix \
      -DGSL_LITE_OPT_INSTALL_COMPAT_HEADER=ON \
      -DCMAKE_VERBOSE_MAKEFILE=1
VERBOSE=$MAKE_VERBOSE make -j$NTHREADS
#[[ $MAKE_CHECK =~ [yYtT] ]] && make test
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
